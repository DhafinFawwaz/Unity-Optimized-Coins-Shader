<h1 align="center">Unity Optimized Coins Shader</h1>

Unity Optimized Coins Shader is a project containing a shader that can be used to render thousands of coins with a very good performance. It can draw all the coins in just 1 batch. Each of the coin including the jumping animation is made with only shader. It doesn't use any Monobehaviour.Update() but all of the coins can still have varying properties like the initial jump phase, flipbook offset, and others. The only drawback is that you can no longer tint the sprite renderer with any color except by setting the alpha value of the color of the SpriteRenderer to 0.


## ✨ Features
- The jump height varies.
- Initial phase of the spinning coins varies.
- Coin spins with the same speed as it's shadow, but the shadow didn't jump.
- Jumps with neither trigonometric function nor if statements but can still jump periodically.
- All of the parameters above can also be set to be with the same values as we want.
- Without any C# Component, which means there's neiher Monobehaviour.Update() nor FixedUpdate(). All of it is made with shader.
- With only 1 texture, 1 material, 1 shader (which are the requirement to make rendering with 1 batch possible).
- All of this can be achieved with the cost of only 1 batch drawcall.

## 🔍 Getting Started
- Navigate to Assets/Scenes and you'll see 4 scenes.
- The scene called "Coin" is the one with the very optimized coin one.
- The other 3 scenes is just for comparison with how people will usually make which is the unoptimized one. Details will be explained below.

## 📖 Explaination
The main problem in optimizing a game is mostly about rendering. One of them is optimizing a lot of moving objects like coins. There are couple of approach that people may think of solving this problem. I'll list some of them below, and the best solution.

### 💡 Solution 1: Monobehaviour.Update()
![With Monobehaviour Update](Images/MonobehaviourUpdate.gif)
This is the worst solution listed here. Each of the coins have a C# Component that has a Monobehaviour.Update() that will be used to make the coin jump with function like `Mathf.Abs(Mathf.Sin(Mathf.PI * Time.time)) * _jumpHeight`. To make the coins have varying jump and flipbook animation, each of them will have a random value for the initial jump phase and the initial flipbook frame. The problem with this approach is that thousands of Monobehaviour.Update() calls is very heavy and will definitely cause a performance hit as you can see in the gif above.

### 💡 Solution 2: Shader
![With Shader](Images/SingleMaterial.gif)
Instead of using Monobehaviour.Update(), we can use shader. This way, each of the coins doesn't need any C# component. We can achieve this with many ways like manipulating vertex displacement and uv coordinate. But the problem is that those coins will do it's animation simultaneously like a military march.

### 💡 Solution 3: Multiple Material
![With Multiple Materials](Images/MultiMaterial.gif)
Instead of just 1 material like in Solution 2, We can use 10 materials, where 5 of them are for the skin, and the other 5 is for the shadow. This way, there will be 5 different kind of the initial jump phase and initial flipbook frame which makes the simultaneous animation less noticable. But now the problem is that, each material has to be drawn in different batch. Which means there will be 10 drawcall batch that has to be done as you can see in the gif above which will cause performance issue.


### 💡 Best Solution: 1 Material With a Very Optimized Shader
![With Very Optimized Shader](Images/Optimized.gif)
The best solution is to use only 1 material with the shader in this project, but with a drawback which makes tinting the sprite is not possible anymore except by setting the alpha value of the color of the SpriteRenderer to 0. But this won't affect anything since we almost never need to tint a rendered sprite. As you can see in the gif above, those thousands of coins is drawn in only 1 batch which is very optimized. There are many tricks used in this shader which some of the worth mentioning are:

#### 🔗 Parabolic Function and Decimals of Time.time
Trigonometric is heavy for shader. Instead of `f(x) = |Sin(πx)|`, we can just use a parabolic function which go to point (0, 0), (0.5, 1), and (1, 0) which is `g(x) = -4(0.5 - x)(0.5 - x) + 1`. As you can't see, `g(x)` is not a periodic function, so we can't make it work with Time.time. But another trick is to use the decimals of Time.time for the input of `g(x)` which always starts from 0 until 0.99 and then back to 0.

#### 🔗 Vertex Displacement
Since it's possible to access the position of the sprite, it means we can manipulate the vertex position by offsetting it to by a certain value. We can utilize the parabolic function above and the vertex color below to achieve this. So instead of using a Monobehaviour.Update() to update the transform.position to make the coin jumping animation, we can use vertex displacement.

#### 🔗 Vertex Color to Control Jump Height
By using the red channel of the vertex color, we can manipulate each of the coin jump height. It's normalized from 0 to 1. Bassically, the jump height will be calculated based on the set JumpHeight of the material multiplied by the red channel of the vertex color. By randomizing the red channel, each of the coin will have varying jump height from 0 to JumpHeight.

#### 🔗 Vertex Color to Control Initial Jump Phase
What Initial Jump Phase means is a value that makes the jump less simultaneous. It can be done by using the green channel of the vertex color. 0.5 of green means its half the periodic, 1 of green means its back to full periodic. It means that when coin with 0 of green just started jumping, coin with 0.25 of green is half of the duration until reaching the top, coin with 0.5 of green just started falling, coin with 0.75 of green is half of the duration until reaching the floor, and coin with 1 of green also just started jumping like the one with 0 of green.

#### 🔗 Vertex Color to Control Initial Flipbook Frame
For this one, it utilize the blue channel of the vertex color. Say there are 8 frame of coin spinning. 0/8 of blue will start the flipbook animation from frame 1, 4/8 of blue will start from frame 5, and 8/8 of blue will start from frame 1.

#### 🔗 Vertex Color to Control How Much the Shader Affect the SpriteRenderer
The alpha channel of the vertex color will take part as an if statement wether the coin can jump and can be tinted or not. 0 of alpha means the coin can't jump but can be tinted, 1 of alpha means the color can jump but can't be tinted. It doesn't actually use any if statements, but created with linear interpolation explained below. Which means 0.4 of alpha will give 40% jump height and 60% tinted. So value other than 0 and 1 shouldn't be used. This trick is usefull to make the shadow of the coin. In a non top down game, this may not be used though.

#### 🔗 Linear Interpolation to Replace If Statements
if statement is known to be very heavy for shader. That's why, there's a way to create an if statement with Linear Interpolation. We can do it by making 0 for off, and 1 for on. But the drawback is that, the in between condition like 0.4 also exist and will be weird. So make sure to only use 1 and 0.

#### 🔗 Divide with Vertex Color (Only for ShaderGraph (Not in this project))
Note that this tricks doesn't exist in this shader, but needs to be done if you're going to use ShaderGraph to recreate this shader. If we use ShaderGraph, the SpriteRenderer is already tinted even without accesing the vertex color. It's possible to lose the ability of tinting the sprite by dividing the output of the shader by the vertex color, but don't forget to clamp it so that it won't be divided by 0 or else it'll explode.


## 📝 License
[MIT](https://choosealicense.com/licenses/mit/)