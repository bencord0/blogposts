Here's one doing the rounds on Facebook.  

    6/2(1+2)=?

  
Of course, the answer depends on how your year 7 skills at algebraic
manipulations are.

Explicitly, we can calculate it like this, in C  

    /* bodmas.c */  
    main(){printf("%d\n",6/2*(1+2));}

  
In Python  

    echo 'print(6/2*(1+2))'|python

  
Of course, the answer is 9. Now that we can get the answers using machines,
let's do it by hand.

Explicitly, what the computers do is calculate (6/2)*(1+2), not the
alternative 6/(2(1+2)). If you can recall some basic maths lessons about what
to do in this situation, remember.  

  

  * **B**rackets
  

  * **O**rder
  

  * **D**ivision
  

  * **M**ultiplication
  

  * **A**ddition
  

  * **S**ubtraction
  
  
No subtraction or exponential operations are required, so follow the list.
Bracket ops first gives us 6/2(3). Divisions reduce us to 3(3). Then finish up
with collecting the constants via the implied multiplication => 9.

Stick this into any conventional calculator and that's the answer one expects.
Most scientific calculators found in secondary maths classes can handle inputs
with brackets, so this works without thinking.

Of course, for those who have known me for a while, have probably heard me
drone on about another method of calculating. Introducing, [Reverse Polish
Notation](http://en.wikipedia.org/wiki/Reverse_Polish_notation). A method of
using calculators without brackets.

With RPN calculators, you input the calculation in a bit of a funny order.
Instead of 1 + 2 = {3}. Where the curly braces denotes the calculator
response. You input 1 2 + {3}. That is, for binary operators (such as O, D, M,
A and S), give the calculator the two inputs, then operate on them[1].

RPN calculators are incredibly simple, well... for a computational point of
view. The only data structure needed is a
[stack](http://en.wikipedia.org/wiki/Stack_%28data_structure%29). Operations
are done by pop some items from the stack, doing the operation, and then
pushing the result back to the stack[2].

Translating our original expression into RPN gives us  

    6  
    <Enter>  
    2  
    / {3}  
    1  
    <Enter>  
    2  
    + {3}  
    * {9}

  
or  

    6  
    <Enter>  
    2  
    <Enter>  
    1  
    <Enter>  
    2  
    + {3}  
    * {6}  
    / {1}

  
And now, the mistake should be apparent

In the first instance, aka. the greedy operator method, you do each of the
operations as soon as the stack has enough data to work on. The exception is
when brackets are encountered in the displayed formula where the stack is
allowed to increase.

The latter instance separates data input and operations, conceptually easier
to understand. Very human. It uses up more memory, but it is much more fun to
press lots of buttons quickly without thinking and letting the answer just pop
out at the end.  

#### Conclusion

  
For absolute clarity in your mathematical expressions, over use brackets or
use spaces to break up the expression into human readable logical units.
Follow [BODMAS](http://en.wikipedia.org/wiki/Order_of_operations) rules, it is
much easier that way. K&R [3] describes THE way that computers evaluate
expressions, let a computer be your check.

RPN always gets the interesting blog posts

[1] It is usual for RPN calculators to have an <Enter> key used to group
digits into numbers.  
[2] Can you think of instances of mathematical operators that don't take two
items from the stack? maybe one? 3? maybe more? Answer in the comments.  
[3] C

**Update:** For more information see [SpikedMath:415](http://spikedmath.com/415.html)  