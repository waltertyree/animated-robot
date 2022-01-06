//
//  ViewController.swift
//  video merge
//
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

  @IBOutlet var beachMovieSwitch: UISwitch!
  @IBOutlet var mountainMovieSwitch: UISwitch!
  @IBOutlet var streamMovieSwitch: UISwitch!

  @IBOutlet var cowMooSwitch: UISwitch!
  
  @IBOutlet var exportMovieButton: UIButton!
  @IBOutlet var mergeWithMutableMovieButton: UIButton!


  @IBOutlet var playerView: UIView!
  var player: AVPlayer?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func mergeMutableMovie(_ sender: Any) {
    let movie = AVMutableComposition()
    let videoTrack = movie.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
    let audioTrack = movie.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)









    do {
      var currentDuration = movie.duration

      if self.streamMovieSwitch.isOn {
      let streamMovie = AVURLAsset(url: Bundle.main.url(forResource: "stream", withExtension: "mov")!)
      let streamRange = CMTimeRangeMake(start: CMTime.zero, duration: streamMovie.duration)
      let streamAudioTrack = streamMovie.tracks(withMediaType: .audio).first!
      let streamVideoTrack = streamMovie.tracks(withMediaType: .video).first!

      try videoTrack?.insertTimeRange(streamRange, of: streamVideoTrack, at: currentDuration)
      try audioTrack?.insertTimeRange(streamRange, of: streamAudioTrack, at: currentDuration)
      videoTrack?.preferredTransform = streamVideoTrack.preferredTransform
      currentDuration = movie.duration
      }

      if self.mountainMovieSwitch.isOn {
        let mountainMovie = AVURLAsset(url: Bundle.main.url(forResource: "mountains", withExtension: "mov")!)
        let mountainRange = CMTimeRangeMake(start: CMTime.zero, duration: mountainMovie.duration)
        let mountainAudioTrack = mountainMovie.tracks(withMediaType: .audio).first!
        let mountainVideoTrack = mountainMovie.tracks(withMediaType: .video).first!

        try videoTrack?.insertTimeRange(mountainRange, of: mountainVideoTrack, at: currentDuration)
        if self.cowMooSwitch.isOn {
          let cowMoo = AVURLAsset(url: Bundle.main.url(forResource: "Cow-moo-sound", withExtension: "mp3")!)
          let cowMooRange = CMTimeRangeMake(start: CMTime.zero, duration: cowMoo.duration)

          try audioTrack?.insertTimeRange(cowMooRange, of: cowMoo.tracks(withMediaType: .audio).first!, at: currentDuration)
        } else {
        try audioTrack?.insertTimeRange(mountainRange, of: mountainAudioTrack, at: currentDuration)
        }
        videoTrack?.preferredTransform = mountainVideoTrack.preferredTransform
        currentDuration = movie.duration
      }

      if self.beachMovieSwitch.isOn {
        let beachMovie = AVURLAsset(url: Bundle.main.url(forResource: "beach", withExtension: "mov")!)
        let beachRange = CMTimeRangeMake(start: CMTime.zero, duration: beachMovie.duration)
        let beachAudioTrack = beachMovie.tracks(withMediaType: .audio).first!
        let beachVideoTrack = beachMovie.tracks(withMediaType: .video).first!

        try videoTrack?.insertTimeRange(beachRange, of: beachVideoTrack, at: currentDuration)
        try audioTrack?.insertTimeRange(beachRange, of: beachAudioTrack, at: currentDuration)
        videoTrack?.preferredTransform = beachVideoTrack.preferredTransform
        currentDuration = movie.duration
      }
    } catch (let error) {
      print("Could not create movie \(error.localizedDescription)")
    }

    self.player = AVPlayer(playerItem: AVPlayerItem(asset: movie))

    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = playerView.layer.bounds
    playerLayer.videoGravity = .resizeAspect

    playerView.layer.sublayers?.removeAll()
    playerView.layer.addSublayer(playerLayer)

    player?.play()
  }

  @IBAction func exportClip(_ sender: Any) {
    guard let assetToExport = self.player?.currentItem?.asset else { return }
    guard let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("exported.mov") else { return }

    mergeWithMutableMovieButton.isEnabled = false

    export(assetToExport, to: outputMovieURL)

  }

  func export(_ asset: AVAsset, to outputMovieURL: URL) {

    //delete any old file
    do {
      try FileManager.default.removeItem(at: outputMovieURL)
    } catch {
      print("Could not remove file (or file doesn't exist) \(error.localizedDescription)")
    }

    //create exporter
    let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)

    //configure exporter
    exporter?.outputURL = outputMovieURL
    exporter?.outputFileType = .mov

    //export!
    exporter?.exportAsynchronously(completionHandler: { [weak exporter] in
      DispatchQueue.main.async {
        if let error = exporter?.error {
          print("failed \(error.localizedDescription)")
        } else {
          self.shareVideoFile(outputMovieURL)
        }
      }

    })
  }

  func shareVideoFile(_ file:URL) {

    mergeWithMutableMovieButton.isEnabled = true

    // Create the Array which includes the files you want to share
    var filesToShare = [Any]()

    // Add the path of the file to the Array
    filesToShare.append(file)

    // Make the activityViewContoller which shows the share-view
    let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

    // Show the share-view
    self.present(activityViewController, animated: true, completion: nil)
  }
}

