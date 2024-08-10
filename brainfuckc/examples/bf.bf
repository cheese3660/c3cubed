#!/usr/bin/bf

[

Brainfuck interpreter in brainfuck

example: 
$ echo '++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<'\
   '+++++++++++++++.>.+++.------.--------.>+.>.!' | bf bf.bf

A '!' separates program input from the input into the program.

Currently limited to 255 char programs as the program counter and etc are one
byte. (Can't run itself yet :()

See <https://github.com/canoon/bfbf/blob/master/bf.rb> for how it works. 

]

[-]+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<[>[-],>[-]+++++++++++++++++++++++++++++++++>>>[-]>>[-
]<<<<<<[->>>>+>>+<<<<<<]>>>>>>[-<<<<<<+>>>>>>]<[-]>[-]<<<<<[->>>>+>+<<<<<]>>>>>[
-<<<<<+>>>>>]<<<[-]+[[-]>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-]<<<[->>+>
+<<<]>>>[-<<<+>>>]<[<<<<[-]+>->->>[-]]<[-]]<<<]<[-]+>>>>[-]>[-]<<<[->>+>+<<<]>>>
[-<<<+>>>]<[<<<<[-]>>>>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-]]<<<[-]>[
-]<<[->+>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-]]<<[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<]>>[-
<<+>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>[->>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>[->>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>[-<>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>
>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<
]<>>]<>>>>>[-]<<[->>+<<]<<<>>[-<<<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<
<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>
]<<<<<[->>>>>+<<<<<]>>]<<<<<<<+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[
-]]<<]>[-]>>>[-]<<[-]>>>[-]<<<<<[-]+>>>>>>>>[-]>>[-]<<<<<<<<<[->>>>>>>+>>+<<<<<<
<<<]>>>>>>>>>[-<<<<<<<<<+>>>>>>>>>]<[-]>[-]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<<<[-]+[[-]>>>[-]>[-]<<<[-
>>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]+>->->>[-]]<
[-]]<<<]<[-]+>>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]>>>>[-]][-]>[-]<<[->
+>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-]]<<<[-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<<<<[-]>>>>
>>>[-]]<<<<<<<[>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<[->>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<+<<<]>>>[-<<<+>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]>[-
]<<<[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<[->>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<+<<<<<]>>>>>[-<<<<<+>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<[->>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<+<<<<<]>>>>>[-<<<<<+>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>[-<>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<
<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<
[->+<]<>>]<>>>>>[-<+<+>>]<[->+<]<<<<>>[-<<<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->
>>>>+<<<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]<>>[-<+>]>[-<+>]>[-<
+>]>[-<+>]<<<<<[->>>>>+<<<<<]>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<[-]>>>[-]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[->>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<][-]+++++++++++++++++++++++++++++++++++++++++++>>>[-]>>[-]<
<<<<<<<[->>>>>>+>>+<<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<[-]>[-]<<<<<[->>>>+>+<<
<<<]>>>>>[-<<<<<+>>>>>]<<<[-]+[[-]>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-
]<<<[->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]+>->->>[-]]<[-]]<<<]<[-]+>>>>[-]>[-]<<<[->>
+>+<<<]>>>[-<<<+>>>]<[<<<<[-]>>>>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-
]]<<<[-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<+>>>>[-]]<<[-]+++++++++++++++++++++++++++
++++++++++++++++++>>>[-]>>[-]<<<<<<<<[->>>>>>+>>+<<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>
>>>>>]<[-]>[-]<<<<<[->>>>+>+<<<<<]>>>>>[-<<<<<+>>>>>]<<<[-]+[[-]>>>[-]>[-]<<<[->
>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]+>->->>[-]]<[
-]]<<<]<[-]+>>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]>>>>[-]][-]>[-]<<[->+
>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-]]<<<[-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<->>>>[-]]<<
[-]++++++++++++++++++++++++++++++++++++++++++++++>>>[-]>>[-]<<<<<<<<[->>>>>>+>>+
<<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<[-]>[-]<<<<<[->>>>+>+<<<<<]>>>>>[-<<<<<+>>
>>>]<<<[-]+[[-]>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-]<<<[->>+>+<<<]>>>[
-<<<+>>>]<[<<<<[-]+>->->>[-]]<[-]]<<<]<[-]+>>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>
]<[<<<<[-]>>>>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-]]<<<[-]>[-]<<[->+>
+<<]>>[-<<+>>]<[<<<<.>>>>[-]]<<[-]++++++++++++++++++++++++++++++++++++++++++++>>
>[-]>>[-]<<<<<<<<[->>>>>>+>>+<<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<[-]>[-]<<<<<[
->>>>+>+<<<<<]>>>>>[-<<<<<+>>>>>]<<<[-]+[[-]>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>
]<[>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]+>->->>[-]]<[-]]<<<]<[-]+>>>>[-]>
[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]>>>>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<
<[-]>>>>[-]]<<<[-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<[-],>>>>[-]]<<[-]++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++>>>[-]>>[-]<<<<<<<<[->>>>>>+>>+<
<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<[-]>[-]<<<<<[->>>>+>+<<<<<]>>>>>[-<<<<<+>>>
>>]<<<[-]+[[-]>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-]<<<[->>+>+<<<]>>>[-
<<<+>>>]<[<<<<[-]+>->->>[-]]<[-]]<<<]<[-]+>>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]
<[<<<<[-]>>>>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-]]<<<[-]>[-]<<[->+>+
<<]>>[-<<+>>]<[>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<<<<]>>
>>>[-<<<<<+>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<<<<<<]>>>
>>>>[-<<<<<<<+>>>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<
<<<<<]>>>>>>>[-<<<<<<<+>>>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-
<>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[->
+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>]<>>>>>[-<<
<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-]<<[->>+<<]<<<<>>[-<+>]>[-<+>]>[-
<+>]>[-<+>]<<<<<[->>>>>+<<<<<]>>[-<<<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<
<<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-
<+>]<<<<<[->>>>>+<<<<<]>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<<<<]>>>>>[-<<
<<<+>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]>[-]<<<[-]<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<<<<<
<]>>>>>>>[-<<<<<<<+>>>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<+<<<<<<<]>>>>>>>[-<<<<<<<+>>>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>[-<>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<
]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>]<>>>>
>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<+<+>>]<[->+<]<<<<<>>[-<+>]>
[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]>>[-<<<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<
[->>>>>+<<<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]<>>[-<+>]>[-<+>]>
[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<[-]>>>>>[-]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[->>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<]<[-]]<<[-]++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++>>>[-]>>[-]<<<<<<<<[->>>>>>+>>+<<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<[-]>[-]<<
<<<[->>>>+>+<<<<<]>>>>>[-<<<<<+>>>>>]<<<[-]+[[-]>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<
+>>>]<[>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]+>->->>[-]]<[-]]<<<]<[-]+>>>>
[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]>>>>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<
[<<<<[-]>>>>[-]]<<<[-]>[-]<<[->+>+<<]>>[-<<+>>]<[>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<[
->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<+<<<<<]>>>>>[-<<<<<+>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<<<[-
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<+<<<<<<<]>>>>>>>[-<<<<<<<+>>>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<
<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<<<<<<]>>>>>>>[-<<<<<<<+>>>>>>>]>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+
<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<
[->+<]<[->+<]<[->+<]<>>]<>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[
-]<<[->>+<<]<<<<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]>>[-<<<>>[-<+>]>
[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>
>+<<<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]>>]<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<[->>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<+<<<<<]>>>>>[-<<<<<+>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>[-]>[-]<<<[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<
<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<<<<<<]>>>>>>>[-<<<<<<<+>>>>>>>]>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
[-]<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<<<<<<]>>>>>>>[-<<<<<<<+>>>>>>>]>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]
<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[-
>+<]<[->+<]<[->+<]<[->+<]<>>]<>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>
>>>>[-<+<+>>]<[->+<]<<<<<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]>>[-<<<
>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<
<<<[->>>>>+<<<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]>>]<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]>>>>>[-]>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>
>>>>+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<[-]]<<[-]++++++++++++++++++++++++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>>>[-]>>[-]<<
<<<<<<[->>>>>>+>>+<<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<[-]>[-]<<<<<[->>>>+>+<<<
<<]>>>>>[-<<<<<+>>>>>]<<<[-]+[[-]>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-]
<<<[->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]+>->->>[-]]<[-]]<<<]<[-]+>>>>[-]>[-]<<<[->>+
>+<<<]>>>[-<<<+>>>]<[<<<<[-]>>>>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-]
]<<<[-]>[-]<<[->+>+<<]>>[-<<+>>]<[>[-]>[-]<<<<<<[->>>>>+>+<<<<<<]>>>>>>[-<<<<<<+
>>>>>>]<[>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<<<<<<<<]
>>>>>>>>>[-<<<<<<<<<+>>>>>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<<<<
]>>>>>[-<<<<<+>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<<<<]>>>>>[
-<<<<<+>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<>>>>>[-<<<<<+>>>>>
]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>
>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>]<>>>>>[-<<<<<+>>>>>]<[->+<]<[
->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-]<<
[->>+<<]<<<<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]<>>[-<+>]>[-<+>]>[-<
+>]>[-<+>]<<<<<[->>>>>+<<<<<]>>[-<<<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<
<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<
+>]<<<<<[->>>>>+<<<<<]>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>
>>[-]][-]+>[-]>[-]<<<<<<<[->>>>>>+>+<<<<<<<]>>>>>>>[-<<<<<<<+>>>>>>>]<[<[-]>[-]]
[-]>[-]<<[->+>+<<]>>[-<<+>>]<[>[-]+[<<<<<<<<<<+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<[->>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<+<]>[-<+>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]>[-]<<<[-]<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<
<<<<<<<<<<]>>>>>>>>>>>>[-<<<<<<<<<<<<+>>>>>>>>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<<<<<<<<[->
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<+<<<<<<<<<<<<]>>>>>>>>>>>>[-<<<<<<<<<<<<+>>>>>>>>>>>>]>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]
<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[-
>+<]<[->+<]<[->+<]<[->+<]<>>]<>>>>>[-<+<+>>]<[->+<]<<<<>>[-<<<>>[-<+>]>[-<+>]>[-
<+>]>[-<+>]<<<<<[->>>>>+<<<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]<
>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<[-]>[-]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<][-]+++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>>
>[-]>>[-]<<<<<<[->>>>+>>+<<<<<<]>>>>>>[-<<<<<<+>>>>>>]<[-]>[-]<<<<<[->>>>+>+<<<<
<]>>>>>[-<<<<<+>>>>>]<<<[-]+[[-]>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-]<
<<[->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]+>->->>[-]]<[-]]<<<]<[-]+>>>>[-]>[-]<<<[->>+>
+<<<]>>>[-<<<+>>>]<[<<<<[-]>>>>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-]]
<<<[-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<+>>>>[-]]<<[-]+++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>>>[-]>>[-]<<<<<
<[->>>>+>>+<<<<<<]>>>>>>[-<<<<<<+>>>>>>]<[-]>[-]<<<<<[->>>>+>+<<<<<]>>>>>[-<<<<<
+>>>>>]<<<[-]+[[-]>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-]<<<[->>+>+<<<]>
>>[-<<<+>>>]<[<<<<[-]+>->->>[-]]<[-]]<<<]<[-]+>>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+
>>>]<[<<<<[-]>>>>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-]]<<<[-]>[-]<<[-
>+>+<<]>>[-<<+>>]<[<<<<->>>>[-]]<<<<]<[-]]<<[-]]<<[-]+++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>>>[-]>>[-]<<<
<<<<<[->>>>>>+>>+<<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<[-]>[-]<<<<<[->>>>+>+<<<<
<]>>>>>[-<<<<<+>>>>>]<<<[-]+[[-]>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-]<
<<[->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]+>->->>[-]]<[-]]<<<]<[-]+>>>>[-]>[-]<<<[->>+>
+<<<]>>>[-<<<+>>>]<[<<<<[-]>>>>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-]]
<<<[-]>[-]<<[->+>+<<]>>[-<<+>>]<[>[-]>[-]<<<<<<[->>>>>+>+<<<<<<]>>>>>>[-<<<<<<+>
>>>>>]<[<<<<->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-]<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+<<
<<<<<<<]>>>>>>>>>[-<<<<<<<<<+>>>>>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>[-]>[-]<<<[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<[->>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<+<<<<<]>>>>>[-<<<<<+>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]<<<<<[->>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<+<<<<<]>>>>>[-<<<<<+>>>>>]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[
-<>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[-
>+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>]<>>>>>[-<
<<<<+>>>>>]<[->+<]<[->+<]<[->+<]<[->+<]<>>>>>>[-<<<<<+>>>>>]<[->+<]<[->+<]<[->+<
]<[->+<]<>>>>>>[-<+<+>>]<[->+<]<<<<<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<
<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]>>[-<<<>>[-<+>]>[-<+>]>[-<+
>]>[-<+>]<<<<<[->>>>>+<<<<<]<>>[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]<>>
[-<+>]>[-<+>]>[-<+>]>[-<+>]<<<<<[->>>>>+<<<<<]>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<[-]>>>>>>>>>[-]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<+>>>>>>>>>+>>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<]<<<<<+>>>>[-]][-]+>[-]>[-]<<<<<<<[->>>>>>+>+<
<<<<<<]>>>>>>>[-<<<<<<<+>>>>>>>]<[<[-]>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<<->
>>>>[-]]<<[-]]<<[-]++++++++++++++++++++++++++++++++++++++++++>>>[-]>>[-]<<<<<<<<
[->>>>>>+>>+<<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<[-]>[-]<<<<<[->>>>+>+<<<<<]>>>
>>[-<<<<<+>>>>>]<<<[-]+[[-]>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-]<<<[->
>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]+>->->>[-]]<[-]]<<<]<[-]+>>>>[-]>[-]<<<[->>+>+<<<]
>>>[-<<<+>>>]<[<<<<[-]>>>>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-]]<<<[-
]>[-]<<[->+>+<<]>>[-<<+>>]<[>>>>[-]<<[-]++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>[-]>>>[-]>>[-]<<<<<
<<<<<<<[->>>>>>>>>>+>>+<<<<<<<<<<<<]>>>>>>>>>>>>[-<<<<<<<<<<<<+>>>>>>>>>>>>]<<<[
-]>>>[-]<<<<<<[->>>+>>>+<<<<<<]>>>>>>[-<<<<<<+>>>>>>]<<[>[-][-]>[-]>[-]<<<[->>+>
+<<<]>>>[-<<<+>>>]<[>[-]>[-]<<<<<[->>>>+>+<<<<<]>>>>>[-<<<<<+>>>>>]<[<<[-]+>>[-]
]<[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<-<->>>[-]]<[-]+>[-]>[-]<<<<[->>>+>+<<<<]>>
>>[-<<<<+>>>>]<[<[-]>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[>[-]>[-]<<<<[->>>+>+<<<<]
>>>>[-<<<<+>>>>]<[<<<<[-]>>>>>[-]<<<<<<<<[->>>+>>>>>+<<<<<<<<]>>>>>>>>[-<<<<<<<<
+>>>>>>>>]<[-]]<<<<<<+>>>>>[-]]<<]>>[-]>[-]<<<<[->>>+>+<<<<]>>>>[-<<<<+>>>>]<[<<
[-]>>>[-]<<<<[->+>>>+<<<<]>>>>[-<<<<+>>>>]<<<<[-]>>>>[-]<<<<<<<[->>>+>>>>+<<<<<<
<]>>>>>>>[-<<<<<<<+>>>>>>>][-]<<<[-<->>>>+<<<]>>>[-<<<+>>>]<[-]]<<[-]>[-]<<<<[->
>>+>+<<<<]>>>>[-<<<<+>>>>]<[>[-]++++++++++++++++++++++++++++++++++++++++++++++++
>[-]<<<<<[->>>>+>+<<<<<]>>>>>[-<<<<<+>>>>>]<.<<<[-]+>>[-]]<<<<[-]++++++++++>[-]>
>>[-]>>[-]<<<[->+>>+<<<]>>>[-<<<+>>>]<<<<<<<[-]>>>>>>>[-]<<<<<<[-<+>>>>>>>+<<<<<
<]>>>>>>[-<<<<<<+>>>>>>]<<[>[-][-]>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-]<
<<<<<<<<[->>>>>>>>+>+<<<<<<<<<]>>>>>>>>>[-<<<<<<<<<+>>>>>>>>>]<[<<[-]+>>[-]]<[-]
][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<-<<<<<->>>>>>>[-]]<[-]+>[-]>[-]<<<<<<<<[->>>>>>
>+>+<<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<[<[-]>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]
<[>[-]>[-]<<<<[->>>+>+<<<<]>>>>[-<<<<+>>>>]<[<<<<<<<<[-]>>>>>>>>>[-]<<<<<<<<[-<+
>>>>>>>>>+<<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<[-]]<<<<<<+>>>>>[-]]<<]>>[-]>[-]
<<<<<<<<[->>>>>>>+>+<<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<[<<[-]>>>[-]<<<<<<<<[-
>>>>>+>>>+<<<<<<<<]>>>>>>>>[-<<<<<<<<+>>>>>>>>]<<<<<<<<[-]>>>>>>>>[-]<<<<<<<[-<+
>>>>>>>>+<<<<<<<]>>>>>>>[-<<<<<<<+>>>>>>>][-]<<<[-<<<<<->>>>>>>>+<<<]>>>[-<<<+>>
>]<[-]]<<[-]>[-]<<<<[->>>+>+<<<<]>>>>[-<<<<+>>>>]<[<<[-]+>>[-]][-]>[-]<<<[->>+>+
<<<]>>>[-<<<+>>>]<[>[-]++++++++++++++++++++++++++++++++++++++++++++++++>[-]<<<<<
[->>>>+>+<<<<<]>>>>>[-<<<<<+>>>>>]<.<[-]][-]++++++++++++++++++++++++++++++++++++
++++++++++++>[-]<<<<<<[->>>>>+>+<<<<<<]>>>>>>[-<<<<<<+>>>>>>]<.<<<<<<[-]]<<<<<<<
+>>>>>>>[-]>>[-]<<<<<<<<<[->>>>>>>+>>+<<<<<<<<<]>>>>>>>>>[-<<<<<<<<<+>>>>>>>>>]<
[-]>[-]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<+>+>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<[->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<
<<<<<<<<<<<<<<<<<]<<<[-]+[[-]>>>[-]>[-]<<<[->>+>+<<<]>>>[-<<<+>>>]<[>[-]>[-]<<<[
->>+>+<<<]>>>[-<<<+>>>]<[<<<<[-]+>->->>[-]]<[-]]<<<]<[-]+>>>>[-]>[-]<<<[->>+>+<<
<]>>>[-<<<+>>>]<[<<<<[-]>>>>[-]][-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<[-]>>>>[-]]<<<
[-]>[-]<<[->+>+<<]>>[-<<+>>]<[<<<<<<<[-]>>>>>>>[-]]<<<<<<<]