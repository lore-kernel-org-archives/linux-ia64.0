From: Rich Altmaier <richa@engr.sgi.com>
Date: Thu, 26 Jul 2001 20:19:56 +0000
Subject: Re: [Linux-ia64] gcc 3.0 question: ILP32 mode ?
Message-Id: <marc-linux-ia64-105590693005930@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dear Jose and others, I would like to caution against proceeding
in this direction (to create ILP32 mode on IA64 systems).
Although it may seem attractive to be able to port code to IA64
without doing the 64bit address corrections, the result is a total
forking of the ABI.

Since 32bit-address and 64bit-address object code cannot be linked
together, persuing 32-bit address becomes a steadily expanding
space.   You have to collect each and every library that you need,
and libraries used by libraries, to get them available in this 32bit
format.   The library developer has to provide two versions.

Since it is always less engineering work to do the 32bit version,
some developers will decide to not do the 64bit version.
Other developers will decide to not do the 32bit version.

The end result will be such fragementation that no application will
find all the libraries it needs, in either format.

Creating a second ABI for IA64 is not to be taken lightly.  It is a big,
big step.   It will echo its result for years.
I urge you to do the 64-bit address cleanup in your code.
For this little bit of up front work, you will promote IA64's success
for the next 10 years.   Other approaches will sink it.

Thanks, Rich
Rich Altmaier
VP of Foundation Software
SGI
richa@sgi.com


Jose Luu wrote:

> This report http://www.linuxia64.org/gcc_summit.2001.06.06.html mentions
> that:
> > the HP-UX version of GCC on IA-64 supports
> >   ILP32 as well as LP64
>
> Is this also available on linux gcc 3.0 ?
> If not, how difficult would it be to make such a version ?
> In case I want to undertake it, are the changes for HP-UX already
> incorporated in the opensource tree ?
>
> Thanks
> Jose


