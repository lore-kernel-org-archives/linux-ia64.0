From: Louay Gammo <lgammo@cs.uwaterloo.ca>
Date: Fri, 14 May 2004 22:23:06 +0000
Subject: Re: Fw: epoll oops on 2.6.x
Message-Id: <40A546CA.6020109@cs.uwaterloo.ca>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020907080901020307090404"
List-Id: <linux-ia64.vger.kernel.org>
References: <40A3EAF6.1000902@cs.uwaterloo.ca>
In-Reply-To: <40A3EAF6.1000902@cs.uwaterloo.ca>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------020907080901020307090404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Davide Libenzi wrote:

>> including some of these oopses as attachements. I am not sure what 
>>the 'normal' bug reporting mechanism is
>>for IA-64 kernels.
>>    
>>
>
>I'm getting this from Randy, since I was not subscribed to linux-ia64. Now 
>I am. I took a quick look at it and so far the clue is completely missing. 
>Only one of the oops actually happen inside epoll, even if the other ones 
>comes typically from __wake_up_common() (others from vfs_read(), that is 
>quite unrelated), that let me think that it might be epoll related (epoll 
>has a wait queue item dropped in). Can you try a few experiments?
>
>1) Disable pre-emption (if enabled)
>2) Load the server thru loopback
>3) #define DEBUG_EPOLL 10
>  
>

I did #1 and #2 and ran my original experiment. I did not get a panic but
I got 0 replies from the server. So I undid the #2 and I got a kernel 
panic (included below).
So I am going to try to overload the server on loopback interface (I think
this is what you are saying) and I will let you know of the results.

I am enclosing the kernel config just in case that might clue anyone to 
a configuration problem.

Thanks,

Louay Gammo

tissimo:~# Unable to handle kernel paging request at virtual address 
000000000001003e
userver[1284]: Oops 8804682956800 [1]
                                     
Pid: 1284, CPU 0, comm:              userver
psr : 0000101008022018 ifs : 8000000000000003 ip  : 
[<a000000100080620>]    Not tainted
ip is at prepare_to_wait_exclusive+0x80/0xe0
unat: 0000000000000000 pfs : 0000000000000288 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 0000000000158659
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100530360 b6  : a000000100002d70 b7  : a000000100581980
f6  : 000000000000000000000 f7  : 000000000000000000000
f8  : 000000000000000000000 f9  : 000000000000000000000
f10 : 000000000000000000000 f11 : 000000000000000000000
r1  : a000000100990000 r2  : e0000040f5f5fd58 r3  : 0000000000000001
r8  : 0000000000000000 r9  : 000000000001003e r10 : e0000040f5f5fd88
r11 : a000000100722900 r12 : e0000040f5f5fd30 r13 : e0000040f5f58000
r14 : e000004043d26160 r15 : e0000040f5f5fd58 r16 : e0000040f5f58000
r17 : e000004043880d48 r18 : 0000001008026018 r19 : 0000000000000000
r20 : 000000003fffff00 r21 : e0000040f5f5fd58 r22 : ffffffffffff0020
r23 : a0000001008e9ab0 r24 : e0000040f5f5fd78 r25 : a0000001008ea198
r26 : e0000040f5f5fd70 r27 : e000004042206088 r28 : e000004042206090
r29 : e0000040422060a8 r30 : e0000040422060b0 r31 : e0000040422060b8
                                                                    
Call Trace:
 [<a000000100017ae0>] show_stack+0x80/0xa0
                                sp=e0000040f5f5f900 bsp=e0000040f5f59378
 [<a00000010003a330>] die+0x130/0x1a0
                                sp=e0000040f5f5fad0 bsp=e0000040f5f59340
 [<a000000100054cd0>] ia64_do_page_fault+0x350/0x920
                                sp=e0000040f5f5fad0 bsp=e0000040f5f592d8
 [<a0000001000118a0>] ia64_leave_kernel+0x0/0x260
                                sp=e0000040f5f5fb60 bsp=e0000040f5f592d8
 [<a000000100080620>] prepare_to_wait_exclusive+0x80/0xe0
                                sp=e0000040f5f5fd30 bsp=e0000040f5f592c0
 [<a000000100530360>] __lock_sock+0x100/0x1a0
                                sp=e0000040f5f5fd30 bsp=e0000040f5f59298
 [<a000000100530f70>] lock_sock+0x50/0xa0
                                sp=e0000040f5f5fd90 bsp=e0000040f5f59278
 [<a0000001005c7610>] inet_accept+0xb0/0x1e0
                                sp=e0000040f5f5fd90 bsp=e0000040f5f59248
 [<a00000010052bdf0>] sys_accept+0x170/0x300
                                sp=e0000040f5f5fda0 bsp=e0000040f5f591a0
 [<a000000100011720>] ia64_ret_from_syscall+0x0/0x20
                                sp=e0000040f5f5fe30 bsp=e0000040f5f591a0
 <0>Kernel panic: Aiee, killing interrupt handler!
In interrupt handler - not syncing

>(Your machine does not look too much in shape looking at INIT messages 
>though)
>
>
>
>- Davide
>
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>  
>


--------------020907080901020307090404
Content-Type: application/x-gzip;
 name="config.gz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="config.gz"

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
--------------020907080901020307090404--

