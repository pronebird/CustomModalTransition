Custom modal transition
=====================

This transition supports both landscape and portrait modes and works on iOS 7 and iOS 8 beta 5. 

![Picture](ScreenRecording.gif)

### Cavets

- Controllers will not properly rotate if orientation changed when presented. There is only one exception, if presented controller is a navigation controller, then rotation works fine. Seems like UIKit bug.
- State restoration is possible but presented VC should restore `transitioningDelegate`, `modalPresentationStyle` and `modalPresentationCapturesStatusBarAppearance`. If you use storyboards then it's easy:

  ```objc
  - (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeInteger:self.modalPresentationStyle forKey:@"modalPresentationStyle"];
    [coder encodeInteger:self.modalPresentationCapturesStatusBarAppearance forKey:@"modalPresentationCapturesStatusBarAppearance"];
    [coder encodeObject:self.transitioningDelegate forKey:@"transitioningDelegate"];
  }
  
  - (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
  	
    self.modalPresentationStyle = [coder decodeIntegerForKey:@"modalPresentationStyle"];
    self.modalPresentationCapturesStatusBarAppearance = [coder decodeIntegerForKey:@"modalPresentationCapturesStatusBarAppearance"];
    self.transitioningDelegate = [coder decodeObjectForKey:@"transitioningDelegate"];
  }
  ```

### Blog post

This project is a part of [my blog post](https://coderwall.com/p/njtb0q). However lots of things changed since I original blog post was published.

- Unwinding works fine, it magically start working if you remove presenting view from container when animation finished.
- Resetting views' frames to container bounds before adding them to container helps to solve issues with misplaced navigation bar
- On iOS 8 beta you would end up with blank screen after dismiss. A simple fix was to add presenting view on window before calling `completeTransition`. Probably it is somehow related to my practice of removing presenting view from container when presenting.
