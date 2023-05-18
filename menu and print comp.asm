.Model small
.stack 100h
.data
msg1 db 13,10,"enter the frist num of the arithmetic series $"
msg2 db 13,10,"enter the change in the arithmetic series $"
msg3 db 13,10,"enter the size of the arithmetic series $" 
msg4 db 13,10,"this is not a number, enter a number $"
crlf db 13,10,"$"
msg5 db 13,10,"yes! the num is in the arithmetic series $"
msg6 db 13,10,"no, the num is not in the arithmetic series $"
current_number db 4 dup(0h)
endThePrinting db " $";; for print the current number with a space
change_number db 0 
size_number db 0
 
test_number db 4 dup(?)
ans db 0

.code
mov ax,@data
mov ds,ax
xor ax,ax 
jmp start 

CheckIfThisIsANumberAndMakeItDecNum proc
push bp
mov bp,sp
push ax
push dx
push si
 
mov si,bp+6;; in si there is the offset of the num
Checking:
cmp ds:si,30h
jb invalid

cmp ds:si,39h
ja invalid

sub ds:si,30h
jmp ending1

invalid:
mov dx,bp+4;; in dx there is the offset of msg4
mov ah,09h
int 21h

mov ah,01h
int 21h
mov ds:si,ax
jmp Checking

ending1:

pop si
pop dx
pop ax
pop bp
ret 6
CheckIfThisIsANumberAndMakeItDecNum endp

 
menu proc 
push bp
mov bp,sp
push ax
push dx
push bx
    
mov dx,[bp+6] ;;in dx there is the offset of msg3
mov ah,09h
int 21h

mov bx,[bp+4] ;;in bx there is the offset of the num
mov ah,01h
int 21h
mov ds:bx,al

pop bx
pop dx
pop ax
pop bp
ret ;; i want to keep the offset of the number to use it in "CheckIfThisIsANumberAndMakeItDecNum"
menu endp 

add_num proc
push bp
mov bp,sp
push si
push ax
push bx
push dx
mov si,[bp+4];; move to ax the offset of the delta num
mov bx,[bp+6];; move to bx the offset of the current num
mov al,[byte ptr ds:si]
add bx,3 

adding:
cmp ds:bx,0h;; i want to add the lest digit of the number(10+2 = 12  not 30)
je invalid1
add ds:bx,al ;; add cant work with 2 memories
jmp CheckIfTheNumIsBiggerThen10  

invalid1:
dec bx
jmp adding 

CheckIfTheNumIsBiggerThen10:
mov dl,[byte ptr ds:bx]
cmp ds:bx,3ah
jae TheNumIsBiggerThen10 
jmp ending2

TheNumIsBiggerThen10: 
cmp bx,[bp+6]  
ja invalid2
mov ds:bx,31h
inc bx
jmp count
 
invalid2:
inc ds:(bx-1) 
cmp bx,[bp+6]+3  ;; if its 4 digits number...
ja ending2

count: 
mov ds:bx,dl
sub ds:bx,0ah
jmp CheckIfTheNumIsBiggerThen10 

ending2:
pop dx
pop bx
pop ax
pop si
pop bp
ret  ;; keeps current_number and change_number offset
add_num endp  

CmpNumbers proc
push bp
mov bp,sp
push si
push ax
push bx
push cx
push dx
mov di,[bp+4];;num 1(offset)
mov bx,[bp+6];;num 2(offset)
mov cx,4
mov si,[bp,8];;ans(offset)

check:
xor ax,ax
mov al,[byte ptr ds:di]
cmp ds:bx ,dx ;; we cant do memory to memory in cmp
inc ax
inc bx
jb incAns
ja addAns
loop check
mov ds:si,2 
jmp ending3
incAns:
inc ds:si
jmp ending3

addAns:
mov ds:si,3

ending3:     
;; if num2 is bigger ans is 3 , num1 is bigger ans is 1,num1=num2 ans is 2
pop cx
pop bx
pop ax
pop si
pop bp
ret 6
CmpNumbers endp     

start:
push offset msg1
lea bx,current_number
push bx 
call menu 
lea bx,msg4
push bx
call CheckIfThisIsANumberAndMakeItDecNum
 
push offset msg2  
lea bx,change_number
push bx
call menu
lea bx,msg4
push bx
call CheckIfThisIsANumberAndMakeItDecNum

push offset msg3
lea bx,size_number
push bx
call menu  
lea bx,msg4
push bx
call CheckIfThisIsANumberAndMakeItDecNum 

lea dx,crlf
mov ah,09h  
int 21h

xor cx,cx
mov cl,size_number
lea dx,current_number   
lea bx, change_number
push dx
push bx
add current_number,30h ;; to print the number   

PrinTheAritmaticSeries:  
mov ah,09h  ;; print the current num with space
int 21h 
call add_num
loop PrinTheAritmaticSeries

EndOf:
end