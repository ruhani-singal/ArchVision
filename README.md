🏗 ArchVision
Design Before You Build

ArchVision is a spatial interior design application built using SwiftUI, ARKit, and RealityKit. It enables users to design rooms in real scale, visualize layouts in 2D & 3D, and preview furniture in Augmented Reality before making real-world decisions.

ArchVision bridges imagination and execution by transforming interior planning into an interactive, intelligent, and immersive experience.

✨ Features
🏠 1. Room Setup System

Custom room dimensions (Width, Length, Height)

Real-time floor area calculation

Wall color selection

Flooring presets

Theme-based style configuration

🧱 2. Multi-View Design Canvas
🎥 Perspective (3D) View

Custom 3D projection engine

Camera orbit via drag gestures

Dynamic lighting simulation

Grid overlay system

Real-time dimension display

📐 Top-Down View

Architectural planning layout

Zoom controls

Scrollable canvas

Grid snapping support

🧍 Elevation View

Wall-based layout visualization

Height-aware object rendering

Vertical scaling accuracy

🪑 3. Interactive Furniture Engine

Categorized furniture catalog

Real-world scaled object dimensions

Drag & drop placement

Object rotation controls

Inspector panel for:

Material selection

Dimension display

Price information

Undo stack (up to 20 actions)

Auto-arrangement algorithm

Budget calculation system

💡 4. Smart Design Suggestions

Theme recommendations:

Modern

Minimalist

Scandinavian

Industrial

Bohemian

Japandi

Lighting presets:

Natural

Warm

Cool

Dramatic

Studio

Color palettes

Professional interior design tips

Animated “AI-style” analysis simulation

📊 5. Space & Budget Analytics

Total objects count

Floor area calculation

Space utilization percentage

Budget tracking

Visual utilization progress bar

📱 6. Augmented Reality Preview (ARKit)

Horizontal & vertical plane detection

Raycasting for accurate placement

Real-world scale modeling

Object rotation in AR

Snapshot capture to Photos

Coaching overlay guidance

AR session interruption handling

Reset & undo functionality

🛠 Tech Stack
Category	Technology
UI Framework	SwiftUI
AR Engine	ARKit
3D Rendering	RealityKit
State Management	ObservableObject (MVVM)
Reactive Updates	Combine
Gesture Handling	SwiftUI Gestures
3D Math	Custom projection calculations
Haptics	UIFeedbackGenerator
Rendering	SwiftUI Canvas
🧠 Architecture

ArchVision follows MVVM (Model-View-ViewModel) architecture.

🔹 Models

FurnitureItem

DesignTheme

MaterialKind

FloorKind

LightPreset

FurnitureCategory

AppScreen

🔹 ViewModels

DesignVM – Core design state management

ARViewModel – AR session handling & placement logic

AppState – Navigation state controller

🔹 Views

Onboarding

Room Setup

Design Canvas (3 modes)

Suggestions

AR Preview

Catalog Sheet

Inspector Panel

Stats View

📦 Imports Used
import SwiftUI
import ARKit
import RealityKit
import Combine

Why Each Is Used

SwiftUI → UI rendering & state-driven interface

ARKit → World tracking, plane detection, raycasting

RealityKit → 3D models, materials, anchors

Combine → Reactive state updates

🧮 Core Systems Implemented

Custom 3D room projection (without SceneKit)

Real-time Canvas-based rendering

Spatial coordinate transformation

Raycast-based AR object placement

Procedural box mesh generation

Material simulation (roughness & metallic parameters)

Undo stack state management

Zoom scaling matrix calculations

Dynamic lighting gradient simulation

Haptic feedback integration

📊 Key Engineering Highlights

100% SwiftUI-based UI

Fully programmatic AR setup

Custom-built perspective projection math

Real-time grid generation

Scrollable & zoomable architectural canvas

AR snapshot capture functionality

State-driven animated UI transitions

Modular reusable components

Environment-based state injection

🎯 Use Cases

Interior designers

Architecture students

Homeowners planning renovations

Real estate staging

Furniture visualization

AR product previews

Educational spatial tools

🚀 Future Improvements

Physically Based Materials (PBR textures)

Real furniture model imports (USDZ)

LiDAR room scanning

AI-based auto-layout optimization

Multi-user collaboration

Cloud save & share

E-commerce integration

Advanced lighting simulation

Real shadow casting

📱 Requirements

iOS 16+

Xcode 15+

Swift Playgrounds compatible

Device with ARKit support

Camera permission enabled

Add to Info.plist:

NSCameraUsageDescription

🔐 Permissions Required

Camera access (for AR functionality)

Photo library access (for saving AR snapshots)

🏆 Project Vision

ArchVision transforms interior design from guesswork into a spatially intelligent, immersive, and data-driven experience.

It empowers users to:

Visualize before purchasing

Optimize space usage

Avoid costly mistakes

Experience designs in real-world AR

Design confidently before building

👩‍💻 Author

Built using SwiftUI & ARKit as an advanced spatial design exploration project.
