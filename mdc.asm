    LDUR X3, [X31, #0];
    LDUR X1, [X31, #8]; @ A
    LDUR X2, [X31, #16]; @ B
while: 
    SUB X4, X1, X2;
    CBZ X4, end; @ A == B
    AND X5, X4, X3; @ X5 = sign(A - B)
    CBZ X5, else; @ A < B
if:
    SUB X1, X1, X2; @ A = A - B
    B while;
else: 
    SUB X2, X2, X1; @ B = B - A
    B while;
end:
    STUR X1, [X31, #0];
    B 0;


