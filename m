From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 03 Jan 2002 03:30:04 +0000
Subject: [Linux-ia64] Re: kgdb internet/ethernet support and {gcc or gdb} bug on test addresses on ia64 port
Message-Id: <marc-linux-ia64-105590698805731@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, 2 Jan 2002 16:27:14 -0800,=20
Piet/Pete Delaney <piet@sgi.com> wrote:
>#include <stdio.h>
>
>
>typedef struct disassemble_info {
>        void (*fprintf_func)();
>} disassemble_info_t;
>
>disassemble_info_t disinfo;
>
>void my_printf(void)
>{
>        (void) printf("Hello World\n");
>}
>
>main(void)
>{
>        disinfo.fprintf_func =3D my_printf;
>        printf("my_printf is at 0x%llx.\n", my_printf);
>        printf("disinfo is at 0x%llx.\n", &disinfo);
>        disinfo.fprintf_func();
>}

You are printing the address of the ia64 function descriptor, not the
function itself.

        printf("&my_printf is at 0x%llx.\n", &my_printf);
	printf("my_printf is at 0x%llx.\n", ((unsigned long *)(&my_printf))[0]);

&my_printf is at 0x40000000000009f0.
my_printf is at 0x4000000000000690.
disinfo is at 0x6000000000000dd8.
Hello World

(gdb) disassemble my_printf
Dump of assembler code for function my_printf:
0x4000000000000690 <my_printf>: [MII]       alloc r34=3Dar.pfs,5,4,0
0x4000000000000691 <my_printf+1>:                   mov r35=3Dr12
0x4000000000000692 <my_printf+2>:                   mov r33=B0

(gdb) disassemble 0x4000000000000690=20
Dump of assembler code for function my_printf:
0x4000000000000690 <my_printf>: [MII]       alloc r34=3Dar.pfs,5,4,0
0x4000000000000691 <my_printf+1>:                   mov r35=3Dr12
0x4000000000000692 <my_printf+2>:                   mov r33=B0



