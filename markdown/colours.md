I didn't know this before, but there is a
[colour space](http://en.wikipedia.org/wiki/Color_space) that is more
appropriate to use for human viewing than
[RGB](http://en.wikipedia.org/wiki/RGB_color_model).

[YUV](http://en.wikipedia.org/wiki/YUV) is made up of 3 components, but
instead of mixes of the colours red, green and blue, it is composed of a
luminescence value, and two chroma. Encoding in such a way can provide better
transmission of pictures for human viewing than using the proportions of RGB.

Translating between the two is simple as $latex \left(\begin{array}{c}Y'\\\U\\
\V\end{array}\right)=\left(\begin{array}{ccc}0.299&0.587&0.114\\\\-0.14713&-0.
28886&0.436\\\ 0.615 & -0.51499 & -0.10001
\end{array}\right)\left(\begin{array}{c}R\\\G\\\B\end{array}\right)$ And the
inverse $latex \left(\begin{array}{c}R\\\G\\\B\end{array}\right)=\left(\begin{
array}{ccc}1&0&1.13983\\\1&-0.39465&-0.58060\\\ 1 & 2.03211 & 0
\end{array}\right)\left(\begin{array}{c}Y'\\\U\\\V\end{array}\right)$ So, how
does this make transmission of pictures better? The eye is typically most
sensitive to brightness changes, which is recorded at the Y value. The U and V
values stores information about colour. Most of this information can be thrown
away. But wait, "Hold on, there's a Y' in the equations above, not a Y. You're
just trying to confuse me." I hear you whine. Y refers to the quantity of
light needed. However, what is more appropriate to encode is the electrical
voltage/signal amplitude, Y', needed to generate Y that we see.  