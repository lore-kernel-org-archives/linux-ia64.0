From: Mario Smarduch <cms063@email.mot.com>
Date: Tue, 04 May 2004 22:15:34 +0000
Subject: Re: mmap() of /dev/kmem issue
Message-Id: <40981606.1CD73DCC@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4097C51D.71EA0BEA@email.mot.com>
In-Reply-To: <4097C51D.71EA0BEA@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant Grundler wrote:

> On Tue, May 04, 2004 at 01:12:21PM -0500, Mario Smarduch wrote:
> > jiffies=0x`grep "D jiffies" /boot/System.map | awk '{ print $1 }'`
> > ./tstmmapkmem $jiffies
>
> Maybe the process is being prempted?
> Ie maybe the problem is the contents are "stale" by the
> time they get displayed on the console/terminal.
> jiffies gets updated 1000/second so on occasion I would
> expect this to happen.
> Maybe pick something that doesn't get updated so frequently?

I can't see how that could have a bearing if both kernel/user
are hitting the cache you should see the same values everytime.

- Mario

>
>
> grant
>
> > #define DEVICE   "/dev/kmem"
> > #define PAGE_MASK (0x4000 - 1) /* page is 16k */
> >
> > #define wmb() __asm__ __volatile__ ("": : :"memory")
> >
> > extern int errno;
> > main(int argc, char *argv[])
> > {
> >    int fd;
> >    ulong mapaddr;
> >    volatile long *jifptr, jiffies;
> >
> >    jiffies = strtoul(argv[1], 0, 16);
> >    printf("jiffies = 0x%lx+AFw-n", jiffies);
> >    printf("pid = %d+AFw-n", getpid());
> >
> >    if((fd = open(DEVICE, O_RDWR)) < 0)
> >         printf("open failed - errno = %d+AFw-n", errno), exit(errno);
> >
> >    jiffies -= IDENBASE;
> >    mapaddr=(ulong) mmap((void *)0x2000000080000000, 0x8000000,
> > PROT_WRITE|PROT_R
> > EAD|PROT_EXEC, MAP_SHARED | MAP_FIXED, fd, jiffies & +AH4-PAGE_MASK);
> >    if(mapaddr = -1UL) {
> >       printf("mmap failed errno = %d+AFw-n", errno);
> >       exit(-1);
> >    }
> >    printf("mapaddr = 0x%lx+AFw-n", mapaddr);
> >    jiffies = mapaddr  (jiffies & PAGE_MASK);
> >    jifptr = (long *) jiffies;
> >    printf("jifptr = 0x%lx+AFw-n", jifptr);
> > pragain:
> >    printf("jiffies: %ld+AFw-n",  *jifptr);
> >
> >    printf("Type return to read again (and flush cashe in meantime):+AFw-n");
> >
> >    getchar();
> >    goto pragain;
> > }
> >
> > - Mario.
> >
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

