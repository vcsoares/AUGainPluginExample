# AUGainPluginExample ![](https://img.shields.io/badge/iOS-13.0-brightgreen)

  * [What it is](#what-it-is)
  * [What it *isn't*](#what-it--isn-t-)
  * [Objective](#objective)
  * [Structure](#structure)
  * [Thoughts on mixing Swift with C++](#thoughts-on-mixing-swift-with-c)

## What it is
- A very simple, but functional, Gain Audio Unit that attenuates the volume of your signal
- A project I've made as a learning exercise and self-challenge while trying to figure out the ins-and-outs of Audio Unit programming
- A mish-mash of Xcode's built-in Audio Unit template project with some tidbits from Apple's own sample code, alongside my own touches
- (Hopefully) a good learning resource for anyone else new to AUv3 programming!

## What it *isn't*
- The most beautiful or well-optimized code around
- A drop-in, set-and-forget template for Audio Unit development (but you can use it as a learning reference!)
- A project based on JUCE/DPF/iPlug/whatever. This is plain Apple-talk, no third-party frameworks involved
- A cross-platform Audio Unit - I've focused solely on the iOS side of things first, to keep things simple

## Objective
This project's main purpose was to learn how to program an Audio Unit plugin from scratch.

One of the first things I've realized when working on this project was that, while Apple's documentation on the AU API can be pretty extensive, it's quite daunting for newcomers. The sample projects made available for download, whilst being really well thought-out and comprehensive, are way too complex for someone trying to write a simple, "hello world" plugin. On the other hand, Xcode's built-in template for AUv3 development seems too barebones, and requires quite a bit of cleanup before being good to go.

Thus, I've realized that the best approach I could take was to use the built-in template as a starting point and try to get it closer to the way the sample projects are laid out, trying to keep it simple as much as possible, until I had a working plugin in hands.

## Structure
This project has 3 build targets:
- **Standalone**

  The standalone app that bundles and registers the plugin within the system, as required by the AUv3 standard for iOS. It simply embeds the plugin's UI when running it, but does **not** process any incoming audio. Use the plugin inside a AUv3 host for that.


- **AppExtension**

  The AUv3 plugin itself, that runs inside any AUv3 host as expected. Since you can attach it to any other app when running it from Xcode, I found it easier to just debug things while running it within Apple's own AUv3Host, that can be downloaded from the Audio Unit docs.
  
  
- **PluginFramework**

  Contains pretty much all the actual code for the plugin. Using a Framework makes it easier to reuse code if needed, and will certainly come in handy if/when trying to create a macOS version of your Audio Unit. As an added benefit, it allows you to easily mix any non-critical parts of your project written in Swift with the core DSP code, that must be written in C++ to ensure glitch-free performance.

## Thoughts on mixing Swift with C++
One of the most interesting things I've found out is that, while Swift does not talk directly to C++, you can use Objective-C++ as the middleman to bridge the two languages. Apple already does that by providing a DSPKernel class, written in plain C++, alongside a DSPKernelAdapter class, written in Objective-C but wrapping the underlying kernel as an ivar.

While this requires an extra bit of care while coding (the core DSP code is pretty much separate from the Audio Unit itself, which in turn is separate from the UI code - it's your job to keep all parameters connected nicely!), it certainly opens up for interesting possibilities - one might wonder if it would be feasible to write a SwiftUI user interface on top of a plugin, for example.
