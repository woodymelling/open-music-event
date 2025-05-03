
#if !SKIP
@_exported import Nuke
#else
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import android.webkit.MimeTypeMap
import coil3.compose.SubcomposeAsyncImage

// SKIP INSERT: import coil3.request.ImageRequest as CoilImageRequest

import coil3.ImageLoader
import coil3.disk.DiskCache
import coil3.memory.MemoryCache

import okio.Path.Companion.toOkioPath

import coil3.size.Size
import coil3.fetch.Fetcher
import coil3.fetch.FetchResult
import coil3.decode.DataSource
import coil3.decode.ImageSource
import coil3.PlatformContext
import coil3.asImage
import kotlin.math.roundToInt
import okio.buffer
import okio.source
#endif

import SwiftUI

public struct CachedAsyncImage<I: View, P: View>: View {


    var requests: [PipelinedRequest]
    let content: (AsyncImagePhase) -> any View
    var placeholder: () -> P


    public init(
        requests: [PipelinedRequest],
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) {
        self.requests = requests
        self.content = { phase in
            switch phase {
            case .empty:
                placeholder()
            case .failure:
                placeholder()
            case .success(let image):
                content(image)
            @unknown default:
                placeholder()
            }
        }
        self.placeholder = placeholder
    }
//
//    public init(
//        requests: [ImageRequest],
//        on pipeline: ImagePipeline = .shared,
//        @ViewBuilder content: @escaping (Image) -> I,
//        @ViewBuilder placeholder: @escaping () -> P
//    ) {
//        self.requests = requests.map { PipelinedRequest(request: $0, on: pipeline) }
//        self.content = content
//        self.placeholder = placeholder
//    }

    #if !SKIP
    @State var model = Model()

    public var body: some View {
        Group {
            if let image = model.image {
                AnyView(content(.success(image)))
            } else {
                AnyView(placeholder())
            }
        }
        .task {
            await model.task(requests: requests)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @Observable
    @MainActor
    class Model {
        #if canImport(SwiftUI)
        public var image: Image? {
            #if os(macOS)
            platformImage.map { Image(nsImage: $0) }
            #elseif os(iOS)
            platformImage.map { Image(uiImage: $0) }
            #elseif SKIP
            platformImage.map { Image(uiImage: $0) }
            #endif
        }
        #endif

        private var platformImage: PlatformImage?
        private var displayedURLOffset: Int = .max

        func task(requests: [PipelinedRequest]) async {

            let validRequests = requests.filter { $0.url != nil }
            guard !validRequests.isEmpty else { return }


            // Get first available in cache
            let cachedImage = validRequests
                .lazy
                .enumerated()
                .compactMap { offset, request in
                    request.cachedImage.map { (image: $0, offset: offset) }
                }
                .first

            if let cachedImage {
                print("Cache hit!")
                self.platformImage = cachedImage.image
                self.displayedURLOffset = cachedImage.offset
            }

            // Get asynchronously from the cache
            await withTaskGroup(of: (offset: Int, result: PlatformImage?).self) { group in
                for (offset, request) in validRequests.enumerated() {
                    group.addTask { [request] in
                        let fetchedImage = try? await request.image()
                        return (offset, fetchedImage)
                    }
                }

                // Only move the image
                for await (offset, image) in group {
                    if let image, offset < displayedURLOffset {
                        self.displayedURLOffset = offset
                        self.platformImage = image
                    }
                }
            }
        }
    }
    #elseif SKIP

    var scale: CGFloat = 1.0

    var request: PipelinedRequest? {
        requests.first { $0.imageRequest.url != nil }
    }

    @Composable
    public override func ComposeContent(context: ComposeContext) {
        guard let request else {
            let _ = self.content(AsyncImagePhase.empty).Compose(context)
            return
        }

        SubcomposeAsyncImage(
            model: request.imageRequest.coil(),
            imageLoader: request.pipeline.imageLoader(),
            contentDescription: nil,
            loading: { _ in
                content(AsyncImagePhase.empty)
                    .Compose(context: context)
            },
            success: { state in

                let image = Image(painter: self.painter, scale: scale)
                content(AsyncImagePhase.success(image))
                    .Compose(context: context)
            },
            error: { state in

                content(AsyncImagePhase.failure(ErrorException(cause: state.result.throwable)))
                    .Compose(context: context)
            }
        )
    }
    #endif

}

#if !SKIP
@dynamicMemberLookup
#endif
public struct PipelinedRequest: Sendable {
    public var imageRequest: ImageRequest
    public var pipeline: ImagePipeline

    public init(request: ImageRequest, on pipeline: ImagePipeline) {
        self.imageRequest = request
        self.pipeline = pipeline
    }

    #if !SKIP
    public func image() async throws -> PlatformImage? {
        try await pipeline.image(for: imageRequest)
    }

    public var cachedImage: PlatformImage? {
        print(self.pipeline.cache)
        return self.pipeline.cache[self.imageRequest]?.image
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<ImageRequest, T>) -> T {
        imageRequest[keyPath: keyPath]
    }
    #endif
}

import OSLog
let imageCachingLogger = Logger(subsystem: "pipeline.imageLoader", category: "ImagePipeline")

// MARK: SKIP Version of NUKEs API
#if SKIP
// SKIP @bridge
public class ImagePipeline {
    public var configuration: Configuration

    public init(configuration: Configuration = .init()) {
        self.configuration = configuration

        imageCachingLogger.log("CREATING NEW IMAGEPIPELINE")
    }

    // SKIP REPLACE: private lateinit var loader: ImageLoader
    private var loader: ImageLoader!

    @Composable
    public func imageLoader() -> ImageLoader {
        // SKIP INSERT: val context = LocalContext.current

        // SKIP REPLACE:
        // if (::loader.isInitialized) { return this.loader }
        if let loader {
            return loader
        }

        imageCachingLogger.log("WOODY: creating new ImageLoader")

        let imageBuilder = ImageLoader.Builder(context)

        if let imageCache = configuration.imageCache {
            imageBuilder.memoryCache {
                MemoryCache.Builder()
                    .maxSizePercent(context, 0.25)
                    .build()
            }
        }

        if let dataCache = configuration.dataCache {
            imageBuilder
                .diskCache {
                    DiskCache.Builder()
                        .directory(context.cacheDir.toOkioPath())
                        .maxSizePercent(0.02)
                        .build()
                }
        }

        self.loader = imageBuilder.build()

        // SKIP REPLACE: return loader
        return loader
    }


    static let shared = ImagePipeline()


    public struct Configuration {
        public var dataCache: DataCache?
        public var imageCache: ImageCache?

        public init(dataCache: DataCache? = nil, imageCache: ImageCache? = nil) {
            self.dataCache = dataCache
            self.imageCache = imageCache
        }

        public static var withDataCache = Configuration()
    }
}

public struct DataCache {
    public let name: String
    public var sizeLimit: Int = 1024*1024*150

    public init(name: String) throws {
        self.name = name
    }
}
public struct ImageCache {
    public init() {}
}

// SKIP @bridge
public struct ImageRequest {
    public init(url: URL?, processors: [ImageProcessor] = []) {
        self.url = url
    }

    public let url: URL?
    public let proacessors: [ImageProcessor] = []

    @Composable
    func coil() -> CoilImageRequest? {
        guard let urlString = url?.absoluteString
        else { return nil }

        return CoilImageRequest.Builder(LocalContext.current)
        //            .fetcherFactory(JarURLFetcher.Factory())
        //            .decoderFactory(coil3.svg.SvgDecoder.Factory())
        //            //.decoderFactory(coil3.gif.GifDecoder.Factory())
        //            .decoderFactory(PdfDecoder.Factory())
            .data(urlString)
        //            .size(Size.ORIGINAL)
            .memoryCacheKey(urlString)
            .diskCacheKey(urlString)
            .build()
    }
}

public struct ImageProcessor {
    @available(*, deprecated, message: "Processors are unimplemented in skip, will just use default coil storage")
    public static func resize(size: CGSize) -> ImageProcessor {
        ImageProcessor()
    }

    @available(*, deprecated, message: "Processors are unimplemented in skip, will just use default coil storage")
    public static func resize(width: CGFloat? = nil, height: CGFloat? = nil) -> ImageProcessor {
        ImageProcessor()
    }
}
#endif





extension ImageRequest {
    public func withPipeline(_ pipeline: ImagePipeline) -> PipelinedRequest {
        PipelinedRequest(request: self, on: pipeline)
    }
}
