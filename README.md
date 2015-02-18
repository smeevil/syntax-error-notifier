# Syntax Error Notifier

### What does it do ?



It will show you an obtrusive error message if your app is crashing due to a syntax error. 

**This package will only work in development**

example : 

<img src='https://s3.amazonaws.com/f.cl.ly/items/0u3G3l3J3o3F0N2m0L3T/Screen%20Recording%202015-02-17%20at%2008.15%20pm.gif' width=500/>

### Why?

I was always waiting on a auto reload of my app after a change. and something it just did not work. I either had to keep an eye on the terminal or manually refresh to see the app crashed due to a syntax error. This will overlay a message and automatically reload if the crash has been mitigated. 

The file generating the parse error is clickable and will open your editor on that file.


### Usage

**Installation:**

~~~js
meteor add smeevil:syntax-error-notifier
~~~

**Basic usage:**

On a detected crash it will automatically pop the overlay.

**Config:**

By default it will check every second if the app is in a functional state again
You can change this by settings the following (checkInterval is in seconds)

There are currently two modes : obtrusive , and unobtrusive

In the example you see the obtrusive version, the unobtrusive version will only show a small red bar at the top of you app containing the error


~~~js
SyntaxErrorNotifier.config={checkInterval: 1, obtrusive: false}
~~~

Licensed under the WTFPL License. See the `LICENSE` file for details.



