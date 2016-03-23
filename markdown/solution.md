> Let us suppose we are given a set of linear equations $latex
\mathbf{A}\mathbf{x}=\mathbf{b}$ to solve. Here $latex \mathbf{A}$ represents
a square matrix of nth order and $latex \mathbf{x}$ and $latex \mathbf{b}$
vectors of $latex n$th order. We may either treat this problem as it stands
and attempt to find $latex \mathbf{x}$, or we may solve the more general
problem of finding the inverse of the matrix $latex \mathbf{A}$, and then
allow it to operate on $latex \mathbf{b}$ giving the required solution or the
equation as $latex \mathbf{x}=\mathbf{A^{-1}}\mathbf{b}$. If we are quite
certain that we only require the solution to be the one set of equations, the
former approach has the advantage of involving less work (about one-third the
number of multiplications by almost all methods). If, however, we wish to
solve a number of sets of equations with the same matrix $latex \mathbf{A}$ it
is more convenient to work out the inverse and apply it to each of the vectors
$latex \mathbf{b}$. This involves, in addition, $latex n^2$ multiplications
and $latex n$ recordings for each vector, compared with a total of about
$latex \frac{1}{3}n^3$ multiplications in an independent solution.

  
\-- Alan Turing (1948)

