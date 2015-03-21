# Unofficial_Hope
#
Disclamer, I do not take credit for any of the work presented here, most of my work has be copy and paste from variouse places. current how to build will be placed in teh wiki  for this repo (see link to the right)

Project staus's
* Utils - builds
* DatabaseManager - builds
* NetworkManager - builds
* Common - builds

* MessageLib - Error	1	error C2338: The C++ Standard doesn't provide a hash for this type.	c:\program files (x86)\microsoft visual studio 11.0\vc\include\xstddef	238	1	MessageLib

* ConnectionServer -Untested
* PingServer - Untested
* LoginServer - Untested
* ChatServer - Untested
* Zone - Untested
* Test -Untested -possibly Unneeded

##What I know so far / to do!##

* The build server bats don't work - needs to be fixed
* Deps are MIA - need to zip and uplaods them somewhere
* Deps need to list what you need to build

# MMOServer #

The MMOServer is the flagship project for the [SWG:ANH Team][1]. It is a cross platform massively multiplayer game server intended to emulate the [Star Wars Galaxies][2] Pre-Combat Upgrade experience. The base of the server is written in C++ with some LUA sprinkled in.


## Building/Installing ##

**Pre-Requisits**

*   CMake 2.8 or higher

    [Download][3] the latest version of CMake for your OS.

*   C++0x Compatible Compiler

    Windows: Visual Studio 2010 or higher is required
    Unix: GCC 4.6 or higher is required
    
### Windows Builds ###

To build the server on Windows simply double-click the BuildServer.bat file in the project root. This will download and build all the dependencies and sources and then generate a /bin directory with the server executables.

### Unix Builds ###

To build the server on Unix platforms run the bootstrap.sh script in the project root. This will download and build all the dependencies and sources. Once the script has completed you can issue further builds from within the "build" directory:

    ./bootstrap.sh
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=/opt/local ..
    make install
    
You can use the -DCMAKE\_INSTALL\_PREFIX flag to specify a custom output directory for the make install command. 

## Useful Links ##

*   [Bugtracker][4]
*   [Wiki][5]
*   [Forum][6]

  [1]: http://swganh.com/
  [2]: http://starwarsgalaxies.com/
  [3]: http://cmake.org/cmake/resources/software.html
  [4]: http://bugtracker.swganh.com/
  [5]: http://wiki.swganh.org/
  [6]: http://www.swganh.com/anh_community/
