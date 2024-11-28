//
//  CVPixelBuffer+Sendable.swift
//  ShootingApp
//
//  Created by Jose on 28/11/2024.
//
//  EXTENSION CREATED TO SILENT THE WARNING WITH NOT SENDABLE OBJECT
//  IT IS A WORK AROUND AND SHOULD BE REMOVED WHEN A NEW VERSION
//  OF XCODE FIXES IT

import CoreML

extension CVPixelBuffer: @unchecked Sendable { }
