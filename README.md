 # GDExtensions Project Template

Pre-made project template to use C++ in the [Godot Game Engine](https://godotengine.org/) with automated type registers.

### Environment
Ubuntu 22.04.2
Godot 4.0
Python 3.10


### Usage 
- Clone the template:
```
git clone git@github.com:Kilthunox/gdextensions_project_template.git
```

- Move into the clone directory:
```
cd gdextensions_project_template
```

- clone the [godot-cpp](https://github.com/godotengine/godot-cpp/) repository:
```
git clone https://github.com/godotengine/godot-cpp/
```
*At the time of this writing, Godot 4.0 was just released. If version 4.0 is
not the current version you will need to checkout the 4.0 branch in godot-cpp*

- Create an example extension using the `new.sh` script:
```
./run/new.sh hello_world
```
*You must use snake case for your file name.*

3. Compile your extension and the godot-cpp bninaries.
```
./run/build.sh
```
*This will take awhile the first time.*

4. Open Godot and import this project then add a new node. If there is a "HelloWorld" node option it worked!



### Sources:
[Godot Game Engine](https://godotengine.org/)
[godot-cpp](https://github.com/godotengine/godot-cpp/)

