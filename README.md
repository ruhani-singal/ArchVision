🍎 ArchVision
Reimagining Architecture Through Augmented Reality

Swift Student Challenge · Apple WWDC Submission Style README

🚀 Overview
ArchVision is an immersive AR-powered architectural visualization app built using SwiftUI + ARKit + RealityKit.

It empowers users to design, place, resize, and explore architectural elements in real space — with precision, realism, and intuitive gestures.

Think: Figma meets RealityKit. In your living room.

✨ Inspiration
Architecture students and designers often struggle to visualize spatial concepts before execution. Traditional 2D drawings fail to communicate depth, materials, and scale. With Apple’s AR ecosystem, we saw an opportunity:

Use ARKit plane detection.

Leverage RealityKit’s PhysicallyBasedMaterial.

Integrate SwiftUI for an elegant UI.

Deliver a seamless Apple-style experience.

Experience Preview


<img width="379" height="603" alt="image" src="https://github.com/user-attachments/assets/adbb6d53-78d8-4ce5-ac23-5b770ee8fd4f" />
<img width="364" height="603" alt="image" src="https://github.com/user-attachments/assets/608f94f6-664d-4744-a6e8-1ff9299adb8e" />
<img width="367" height="603" alt="image" src="https://github.com/user-attachments/assets/ba28ea80-48ae-434f-b159-28e3effb7639" />
<img width="348" height="603" alt="image" src="https://github.com/user-attachments/assets/45f8df62-8d25-400f-88c9-80d22c23010e" />
<img width="350" height="603" alt="image" src="https://github.com/user-attachments/assets/9fa0493e-516b-407d-a276-c64ca76d1aec" />
<img width="348" height="603" alt="image" src="https://github.com/user-attachments/assets/a2897a7d-a1ff-49d8-857d-7608daf8788d" />


🧠 Core Features
🏗 Intelligent Object Placement

Plane detection using ARKit.

Grid-based snapping.

User-controlled positioning (no blind placement).

📏 Dynamic Scaling & Resizing

Pinch to resize objects.

Real-time scaling with visual feedback.

Maintain proportional integrity.

🔍 Zoomable AR Grid

Interactive zoom controls.

Precision editing mode.

Smooth camera movement.

🪵 Realistic Materials

Utilizes PhysicallyBasedMaterial().

Wood, marble, and metal textures.

Roughness & normal maps for depth realism.

🎨 Apple-Level UI

Clean SwiftUI components.

Subtle animations.

SF Symbols integration.

Accessibility-first design.

🛠 Built With
SwiftUI

ARKit

RealityKit

Xcode

Apple’s Human Interface Guidelines

🏛 System Architecture
User Interaction (SwiftUI)

ARView Container

Plane Detection (ARKit)

3D Entity Rendering (RealityKit)

Physically Based Materials

Modular architecture ensures:

Scalability

Clean separation of concerns

Future feature expansion (multi-user, cloud sync)

🎯 Problem Statement
Challenge	Impact
Lack of real-world visualization	Design misinterpretation
Limited interaction in traditional CAD	Reduced engagement
No real-time scale validation	Costly implementation errors
💡 Our Solution

ArchVision provides real-scale AR object visualization, interactive design manipulation, and photorealistic rendering—all powered natively within Apple’s ecosystem.

🌍 Who Benefits?
Architecture Students

Interior Designers

Real Estate Developers

AR Enthusiasts

Educational Institutions

📈 Future Roadmap
🌐 Multi-user collaboration via SharePlay

☁️ Cloud model sync

🧠 AI-assisted room recommendations

🏢 Prebuilt architectural templates

🎭 Advanced material library

🏆 Why This Fits WWDC
Leverages Apple’s core technologies: Deep integration of ARKit and RealityKit.

Innovation: Moves architectural design from 2D screens to 3D space.

Clean SwiftUI-first architecture: Modern, declarative, and efficient code.

Impact: Educational and professional utility.

🧑‍💻 Developer
Ruhani Singal
Swift Developer · AR Enthusiast · Hackathon Builder

“Technology should not just build structures — it should help us experience them.”

📦 Installation
Clone the repository:

Bash
git clone https://github.com/ruhani-singal/ArchVision.git
Navigate and Open:

Bash
cd ArchVision
open ArchVision.xcodeproj
Requirements:

iPad/iPhone with LiDAR (Recommended)

iOS 16+

Xcode 15+
