# Setting PATH for Python 3.6
# The original version is saved in .bash_profile.pysave
PATH="~/Library/Python/3.6/bin:/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"
export PATH
export PATH="~/Documents/scripts:${PATH}"
export PATH="/usr/local/Cellar/distcc:${PATH}"
export PATH="/usr/local/opt/protobuf@2.5/bin:$PATH"
export ANDROID_NDK_ROOT="/Users/aaroncantor/Development/android-ndk/android-ndk-r13b"
export ANDROID_SDK_ROOT="/Users/aaroncantor/Library/Android/sdk"
export ANDROID_HOME="/Users/aaroncantor/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"

export DISTCC_ENABLED=true

# Be wary of choosing < 8, since sword fighting during compilation is exhausting.
export NUMBER_OF_PROCESSORS=8
export DISTCC_CURRENT_BUILD_ENABLED=true

export DISTCC_FALLBACK=0
