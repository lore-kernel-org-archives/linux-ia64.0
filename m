From: Andy Isaacson <adi@hexapodia.org>
Date: Thu, 06 Mar 2003 00:24:25 +0000
Subject: Re: [Linux-ia64] munmap() slowness
Message-Id: <marc-linux-ia64-105590709805983@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805979@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805979@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 05, 2003 at 03:45:24PM -0800, David Mosberger wrote:
> Andy> munmap on a 15TB anonymous area is extremely slow on our Itanium 2 box.
> Andy> #include <sys/mman.h>
> Andy> int main(void) {
> Andy> size_t s = 1024*1024*1024*1024L * 15;
> Andy> munmap(mmap(0, s, PROT_READ|PROT_WRITE,
> Andy> MAP_NORESERVE|MAP_PRIVATE|MAP_ANONYMOUS, -1, 0),
> Andy> s);
> Andy> return 0;
> Andy> }
>
> Andy> ./a.out 0.00s user 1.51s system 100% cpu 1.515 total
>
> Andy> The kernel is 2.4.19 plus linux-2.4.19-ia64-020821.diff.gz (plus some
> Andy> local changes that shouldn't be relevant).
> 
> $ uname -r
> 2.4.19-mckinley-smp
> $ /usr/bin/time ./a.out
> 0.00user 0.00system 0:00.00elapsed 100%CPU (0avgtext+0avgdata 0maxresident)k
> 0inputs+0outputs (44major+13minor)pagefaults 0swaps

My bad, it turns out I logged into a different machine which is running
2.4.18-e.12smp from some interim RHAS 2.1 release.  When I re-ran the
test on the correct 2.4.19 box, the performance is fine.

-andy

