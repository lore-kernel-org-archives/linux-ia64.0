From: Jay Lan <jlan@sgi.com>
Date: Wed, 16 Aug 2006 22:34:52 +0000
Subject: Re: IA64 Kexec-Kdump kernel patch
Message-Id: <44E39D8C.2060005@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155538073.2585.44.camel@linux-znh>
In-Reply-To: <1155538073.2585.44.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou Nan hai wrote:
> On Wed, 2006-08-16 at 03:15, Jay Lan wrote:
> 
>>Zou Nan hai wrote:
>>
> 
>   Did you pass the correct kernel parameter to --append?
>   It seems that root filesystem was not able to be mounted.
> 

I finally was able to boot up the crash dump kernel.
Unfortunately the 'cp vmcore /var/tmp' crashed due to
out of memory. :(

The memory on the regular kernel showed:
[root@holism tmp]# free
              total       used       free     shared    buffers     cached
Mem:        805312     443520     361792          0      36288     295936
-/+ buffers/cache:     111296     694016
Swap:      6143968          0    6143968

and the memory on the crash dump kernel showed:
[root@holism tmp]# free
              total       used       free     shared    buffers     cached
Mem:         47776      45952       1824          0       1056      11856
-/+ buffers/cache:      33040      14736
Swap:      6143968      54720    6089248


It came down from 805312 k  to 47776 k with only 1824 free.
How much memory do i need to do a 'cp /proc/vmcore /var/tmp'?

Thanks,
  - jay


