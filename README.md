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

The project requires diverse a-grade 3rd-party open source runtime libraries.

1. Goto the directory 'include' and download a most recent version of these 
libraries.
2. Add these source paths to the browsing path of Delphi IDE. 

As soon as you installed all prerequisites, we should build the project. 

1. Open the project group file at the directory 'make' and execute "Build All". 
2. If the compilation goes smooth, please run the unittests.
3. Install the VCL package 'dui'.
4. Add the source paths to the browsing path of Delphi IDE. 

Now the dutil library is ready to use and have fun.

## Roadmap ##

Here are some development goals to be reached in 2014.

1. Introduce an Inter-Process-Communication package. The IPC approach is based 
on Windows message exchange. The communication protocal is Json RPC. The code 
is ready for a while, I still need time to prepare some examples. 
2. Introduce more native looking VCL components from my previous project 
https://code.google.com/p/native-look-vcl/
