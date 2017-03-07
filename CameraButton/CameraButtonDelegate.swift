//
//  CameraButtonDelegate.swift
//  CameraButton
//
//  Created by Jordan Kay on 3/7/17.
//  Copyright © 2017 Squareknot. All rights reserved.
//

/**
 * Protocol outlining button events the delegate is notified of.
 */
public protocol CameraButtonDelegate: class {
    /**
     * Called when the button is pressed in photo mode.
     */
    func cameraButtonDidTakePhoto(_ cameraButton: CameraButton)
    
    /**
     * Called when the button is pressed in video mode when not already recording.
     */
    func cameraButtonDidStartRecordingVideo(_ cameraButton: CameraButton)
    
    /**
     * Called when the button is pressed in video mode when already recording.
     */
    func cameraButtonDidStopRecordingVideo(_ cameraButton: CameraButton)
}
