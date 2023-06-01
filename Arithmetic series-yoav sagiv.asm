.Model small
.stack 100h
.data
msg1 db 13,10,"enter the first num of the arithmetic series $";;Notice of the first number request
msg2 db 13,10,"enter the change in the arithmetic series $" ;;Notice of delta request
msg3 db 13,10,"enter the size of the arithmetic series $" ;;Notice of size request 
msg4 db 13,10,"this is not a number, enter a number $" ;;Error Message
crlf db 13,10,"$" ;dropped a line
msg5 db 13,10,"enter a num that you think that its in the arithmetic series $" ;request for a number that may be in the series
msg6 db 13,10,"yes! the num is in the arithmetic series $" ;A positive message
msg7 db 13,10,"no, the num is not in the arithmetic series $";negative message

first_number db 5,?,5 dup(0h);;the initial number of the series 
current_number db 10 dup(0h);;The current number of the series (see below)
endThePrinting db ' $';; for print the current number with a space
change_number db  5,?,5 dup(0h);;The delta of the series 
size_number db  5,?,5 dup(0h);;The size of the series 
test_number db 11,?,11 dup(0h);;The number that may be in the series
ans db 0;;

.code
mov ax,@data
mov ds,ax
xor ax,ax 
jmp start 

;;Receives the address of a message and of a variable
;;Prints the message 
;;receives a number for the address of the variable 
menu proc 
push bp
mov bp,sp
push ax
push dx
push bx
    
mov dx,[bp+6] ;;in dx there is the offset of msg3
mov ah,09h
int 21h

mov dx,[bp+4] ;;in bx there is the offset of the num
mov ah,0ah
int 21h

pop bx
pop dx
pop ax
pop bp
ret 6
menu endp

;;Gets a number address
;;Checks if it is above 30H and below 39H
;;Then raises the memory address by 1 and check again
;;Thus checking if the entered number is indeed a number
;;1.If it is a number, finish the procedure
;;2.If it is not, print a message that the procedure has received
;;and receive a number and check it again 
CheckIfThisIsANumberAndMakeItDecNum proc
push bp
mov bp,sp
push ax
push dx
push si
 
mov si,bp+6;; in si there is the offset of the num
mov cx,4 
Checking:
cmp ds:si,30h
jb invalid

cmp ds:si,39h
ja invalid

inc si
loop Checking 
jmp ending1

invalid:
cmp ds:si,0Dh ;; there is one D that will get in every number becuse the users need to prese enter...
je ending1 
mov dx,bp+4;; in dx there is the offset of msg4
mov ah,09h
int 21h

mov ah,0ah
int 21h
mov si,bp+4
jmp Checking

ending1:
pop si
pop dx
pop ax
pop bp
ret 
CheckIfThisIsANumberAndMakeItDecNum endp 

;;Receives an address of a number
;;Checking how many numbers he has
;;Put a few places in the BX
;;Moves the numbers to the right by BX
FillNum proc
push bp
mov bp,sp
push si
push ax
push bx 
push dx
push cx
xor ax,ax
xor cx,cx
mov bx,[bp+4];;num(offset)
mov ax,[bp+6];;digits num
cmp ax,0h
je ending4

mov cx,4
mov bx,[bp+4]
sub cx,ax;;in cx there is the nums of the digits in the number 
add bx,cx
dec bx;;in bx there is the offset of the lost digit of the number

MoveTheDigitsASide:
mov si, bx
add si,ax;;in si there is the offset of where the digit need to move to
mov dl,[byte ptr ds:bx] 
mov ds:si,dl
mov ds:bx,0h
dec bx
loop MoveTheDigitsASide

ending4: 
pop cx
pop dx
pop bx
pop ax
pop si
pop bp
ret 6
FillNum endp

;;Gets the current number and the change of the series
;;Adds the numbers by digits
;;do cmp if the number is bigger than 10D
;;1.If not, go to the next digit
;;2. If so, Sub from the digit 10D 
;;increase the next digit by 1 
;;and check if the second digit is bigger than 10D

add_num proc
push bp
mov bp,sp
push si
push ax
push bx
push dx
push cx
push di
mov si,[bp+4];; move to ax the offset of the lest digit of delta num
mov bx,[bp+6];; move to bx the offset of the lest digit of current num
xor cx,cx
mov cx,4 

adding: 
mov al,[byte ptr ds:si]
cmp al,0h
je adder
sub al,30h
adder: 
add ds:bx,al ;; add cant work with 2 memories 
cmp ds:bx,0h 
mov di,bx
je CheckIfTheNumIsBiggerThen10 
;;add ds:bx,30h

CheckIfTheNumIsBiggerThen10:
mov dl,[byte ptr ds:bx];;to keep it for count
cmp ds:bx,3ah
jae TheNumIsBiggerThen10
mov bx,di
dec bx 
dec si
loop adding
jmp ending2
TheNumIsBiggerThen10:
dec bx
cmp ds:bx,30h
jae JustInc
add ds:bx,30h 
JustInc:  
inc ds:bx


count:
inc bx
cmp bx,[bp+6]-9  ;; if its 10 digits number...
jb ending2 
mov ds:bx,dl
sub ds:bx,0ah
dec bx
jmp CheckIfTheNumIsBiggerThen10
mov bx,di
;;dec bx
dec si                     
loop adding

ending2:
pop di
pop cx
pop dx
pop bx
pop ax
pop si
pop bp
ret  ;; keeps current_number and change_number offset
add_num endp

;;Gets the address of the first and current number
;;Makes a loop that puts every digit 
;;from the first number in the cell of the current number 
PutfirstNumInCurrnt proc
push bp
mov bp,sp
push si
push ax
push bx
push cx

mov si,[bp+4];;the offset of current number
mov bx,[bp+6];;the offset of first number
add si,9
add bx,3;; i want to go to the lest index 
mov cx,4
mooving:
mov al,[byte ptr ds:bx]
mov [byte ptr ds:si],al
dec si
dec bx
loop mooving

pop cx
pop bx
pop ax
pop si
pop bp
ret 6
PutfirstNumInCurrnt endp

;get the offset of the size and ans
;;Go through each digit in the number of the size
;;If all the digits are 0, you will end the procedure
;;If we reached a number other than 0, put 1 in ANS
;;Then check if the number is equal to 0
;;If not, simply lower the number by 1 and finish the procedure
;;If so, put a 9 in that digit and do the test for the next digit
dec_num proc
push bp
mov bp,sp
push si
push bx
push cx
mov bx,[bp+4];;the offset of the lest digit of size num 
mov si,[bp+6];;the offset of ans 

mov cx,4
cheakIftheAllNumIs0:
cmp ds:bx,0
jne ans1
dec bx
loop cheakIftheAllNumIs0 
mov ds:si,0
jmp ending5
ans1:
mov ds:si,1
mov bx,[bp+4]

minus:
cmp ds:bx,0h
je its0
dec ds:bx
jmp ending5
its0:
mov ds:bx,9h
dec bx
jmp minus

ending5:
pop cx
pop bx
pop si
pop bp
ret 6
dec_num endp
    
;;gets the addresses of the current number
;;the number we want to check and our answer
;;Checks each digit (from largest to smallest)
;;of the numbers if it is equal/larger/smaller
;;If it is equal, move to the next digit and check again. 
;;If current is big, put in ans 3. 
;;If current is small, put in ans 1
;;If the loop is finished and the numbers are equal, put in ans 2.    
CmpNumbers proc
push bp
mov bp,sp
push si
push ax
push bx
push cx
push dx
push di
mov di,[bp+6];;test_number(offset)
mov bx,[bp+8];;current_number(offset)
mov cx,4
mov si,[bp+4];;ans(offset)

check:
xor ax,ax
mov al,[byte ptr ds:di]
cmp ds:bx,al ;; we cant do memory to memory in cmp
jb AnsIs1
ja AnsIs3
inc di
inc bx ;; to go to the next digit
loop check 
mov [byte ptr ds:si],02h 
jmp ending3 

AnsIs1:
mov [byte ptr ds:si],01h
jmp ending3

AnsIs3:
mov [byte ptr ds:si],03h

ending3:     
pop di
pop dx
pop cx
pop bx
pop ax
pop si
pop bp
ret 6
CmpNumbers endp 

 

start:
push offset msg1
lea bx,first_number
push bx 
call menu
add bx,2
push bx                                       
lea bx,msg4     ;;get frist num
push bx
call CheckIfThisIsANumberAndMakeItDecNum

lea bx,first_number
inc bx
xor ax,ax 
mov al,[bx]
push ax
inc bx
push bx 
call FillNum

push offset msg2  
lea bx,change_number
push bx
call menu
add bx,2         ;; get delta num
push bx
lea bx,msg4
push bx
call CheckIfThisIsANumberAndMakeItDecNum
lea bx,change_number
inc bx
xor ax,ax 
mov al,[bx]
push ax
inc bx
push bx  
call FillNum

push offset msg3
lea bx,size_number
push bx
call menu        ;;get size num
add bx,2
push bx  
lea bx,msg4
push bx
call CheckIfThisIsANumberAndMakeItDecNum 
lea bx,size_number 
inc bx
xor ax,ax 
mov al,[bx]
push ax
inc bx
push bx 
call FillNum

lea dx,crlf
mov ah,09h      ;;drop a line
int 21h 
 
lea bx,first_number 
add bx,2
push bx
lea bx,current_number
push bx
call PutfirstNumInCurrnt

lea bx,size_number
add bx,2 
mov cx,4

MakeSizeNumber:
cmp [bx],0
je Doloop            
sub [bx],30h
Doloop:
inc bx
loop MakeSizeNumber 

lea dx,current_number
mov ah,09h             ;; print the frist number
int 21h
 
PrinTheAritmaticSeries:
lea bx,ans
push bx
lea bx,size_number
add bx,5
push bx
call dec_num
cmp ans,0
je testNum
 
lea bx,current_number  ;;the lest digit in the number
add bx,9
push bx
lea bx,change_number
add bx,5               ;;the lest digit in the number
push bx  
call add_num 

lea dx,current_number
add dx,2 
mov ah,09h  ;; print the current num with space
int 21h 
jmp PrinTheAritmaticSeries 


testNum:
lea bx,current_number
add bx,5;;to the 5th digit ;cheak if the current num is more then 4 digits number
cmp [bx],30h
jae EndOf

lea bx,msg5
push bx
lea bx,test_number
push bx
call menu
add bx,2  ;; get num(maybe in the series}
push bx  
lea bx,msg4
push bx
call CheckIfThisIsANumberAndMakeItDecNum 
lea bx,test_number 
inc bx
xor ax,ax 
mov al,[bx]
push ax
inc bx
push bx 
call FillNum

CheckIfTheNumIsIN:
lea dx,test_number 
add dx,2;; the start of the test_number 
push dx ;; test_number(offset)
lea dx,current_number
add dx,6
push dx;;current_number(offset)  
lea dx,ans
push dx;;ans(offset) 
Call CmpNumbers

cmp ans,2
jb ItsNot
ja running
lea dx,msg6
mov ah,09h
int 21h
jmp EndOf  
ItsNot:
lea dx,msg7
mov ah,09h
int 21h
jmp EndOf
running: 
lea bx,current_number 
add bx,9
push bx
lea bx,change_number
add bx,5
push bx       
call add_num
jmp CheckIfTheNumIsIN

EndOf: 
end