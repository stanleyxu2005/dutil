# Delphi Util Library #

The project is inspired by the library Tango from the language D world. We want
to make dutil to be a cohesive and comprehensive library for general purpose 
usage. The code is written based on the Design by Contract principle. Pre- and 
post-conditions are used to ensure the code works exactly as expected.

IMPORTANT: Considering about using the exciting new Delphi language features 
(such as for-in-loop, generic types, advances record type, class constructor, 
Unicode support), the code might not be compatible with old Delphi compilers. 
We recommend you use Embarcadero RAD Studio XE2 or higher.

We hope you enjoy using the library, although the usage is poorly documented. 
We would be very appreciated, if you can help us to make it better.

## Getting Started ##

The project requires diverse 3rd-party open source runtime libraries.

1. Goto the directory `include` and download these open source libraries. 
   a. These libraries does not have any license issues. 
   b. If you do not want to use these libraries, you can simply remove related 
      units and unittests.
2. Add these source paths to the browsing path of Delphi IDE. 

As soon as you installed all prerequisites, we should build the project. 

1. Open the project group file at the directory `make` and execute `Build All`. 
2. Run the unittests from project manager.
3. Install the VCL package `dui`.
4. Add the source paths to the browsing path of Delphi IDE. 

Now the dutil library is ready to use and have fun.

## Notes ##

Welcome you to create tickets on github or mail me for feature requests.

Please also checkout https://github.com/stanleyxu2005/native-looking-vcl