From: "Qiu HongBing" <qiuhb@necas.nec.co.jp>
Date: Tue, 13 Nov 2001 04:12:38 +0000
Subject: Re: [Linux-ia64] do me a favor
Message-Id: <marc-linux-ia64-105590698805487@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805482@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Excuse me,
But I want to avoid this problem. How to do?
Thanks.

    --Qiu HongBing


> temp will be aligned when storage is allocated for it
> d[16] just happens to work because it is aligned
> any address that is not divisible by 8 can be considered unaligned
>
> But next example happened same.
>
> char d[20][20];
> ...
>
entry[2]=newtEntry(-1,-1,d[2],10,(char**)&d[11],NEWT_ENTRY_SCROLL);--->>outp
> ut the unaligned access
>
> but , If I changed it to as follows and it is OK.
>
>
> char d[20][20];
> ...
> {
> char temp[20];
> sprintf(temp,"%s",d[11]);
>
entry[2]=newtEntry(-1,-1,d[2],10,(char**)&temp/*&d[11]*/,NEWT_ENTRY_SCROLL);
> sprintf(d[11],"%s",temp);
> }
> ...
>
> I want to know why.
> That's all.
> Thanks.
>
> >
> > > My problem is as follows:
> > >
> > > struct aa{
> > > unsigned short a;
> > > unsigned short b;
> > > unsigned short c;
> > > unsigned short d;
> > > unsigned int e;
> > > unsigned int f;
> > > unsigned int g;
> > > unsigned int h;
> > > unsigned short i;
> > > }
> > > ...
> > > struct aa *a1;
> > > ...
> > >
> > > fun1(char *,unsigned int *,char *,char *,unsigned int * temp,unsigned
> int *)
> > > {
> > > ...
> > > *temp;
> > > ...
> > > }
> > > ...
> > >
> > > fun1(a,b,c,d,&a1->b,e);
> > > ...
> > >
> > > On IA64 Linux RedHat 7.1(2.4.3-3), when the program run to
> > > fun1(a,b,c,d,&a1->b,e), the kernel write into syslog some message
which
> is
> > > "Nov  5 10:12:02 sdv2 kernel: ESMmlx(7837): unaligned access to
> > > 0x600000000001684c, ip=0x2000000000624370".
> >
> > The reason is obvious: fun1 expects temp to be a pointer to unsigned
> > int, but you're passing it &a1->b, which is a pointer to unsigned
> > short.  The compiler should have actually warned you about that.
> >
> > > But if I modify the source as follows and it is OK. I dont know why.
So
> I
> > > want to get some help to solve the real cause.
> >
> > Then, either define the b member as unsigned int, or the temp
> > parameter as pointer to unsigned short.
> >
> > Dan
> >
> >



