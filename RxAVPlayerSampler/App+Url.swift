//
//  App+Url.swift
//  RxAVPlayerSampler
//
//  Created by yoshida hiroyuki on 2016/12/16.
//  Copyright © 2016年 hryk224. All rights reserved.
//

extension App {
    struct Video {
        static let shared = Video()
        let url = "http://pfstatic.blog-video.jp/output/hls/TdiuySBmrnrmMI6FGdHWoCq0/TdiuySBmrnrmMI6FGdHWoCq0_.m3u8"
    }
    struct Image {
        static let shared = Image()
        let url = "http://stat.sb-amebame.com/pub/content/8517/moviepf/thumbnail_20161207183052493.jpg"
    }
    static var video: Video {
        return App.Video.shared
    }
    static var image: Image {
        return App.Image.shared
    }
}
