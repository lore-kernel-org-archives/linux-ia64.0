From: Keith Owens <kaos@sgi.com>
Date: Thu, 03 Jan 2002 08:46:09 +0000
Subject: [Linux-ia64] Re: Calling functions via function descriptors saved with cast needed for ia64 code. Il
Message-Id: <marc-linux-ia64-105590698805735@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 3 Jan 2002 00:18:33 -0800, 
Piet/Pete Delaney <piet@sgi.com> wrote:
>On Wed, Jan 02, 2002 at 09:46:35PM -0800, Piet/Pete Delaney wrote:
>$2 = {
>  fprintf_func = 0x400000000006cfb0 <dis_fprintf>, 		<-- Pointer to function seems to be ok

That is exactly what you are not supposed to do.  Function pointers
must be treated as opaque cookies.  You can pass them around, assign
them, call the function via the pointer but _never_ assume that
function pointers point to the function.

Dereferencing an ia64 function pointer to get the address of the
function code is only valid for printing the real function address.
You cannot call the function using the dereferenced address because you
do not have the correct environment, you discarded the global data
pointer when you dereferenced the function pointer.

The only time this works on ia64 and ppc64 is in specialized
environments where you know that the global data pointer is not
changing across a function call.  The Linux kernel uses -mconstant-gp
as a performance optimization, intra kernel function calls by name use
the same global pointer so we can skip the save/load/restore cycle for
the global pointer.  Indirect function calls require the function
descriptor, even if you are calling another routine in the kernel.
Calls to module code always have a different global pointer.


