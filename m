From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 26 Sep 2003 14:54:23 +0000
Subject: Re: vhpt_miss handler question?
Message-Id: <marc-linux-ia64-106458822728089@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106458752027199@msgid-missing>
In-Reply-To: <marc-linux-ia64-106458752027199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 26 Sep 2003 09:43:55 -0500, 
Mario Smarduch <cms063@email.mot.com> wrote:
>Some work I'm doing has taken me to the vhpt_miss
>handler. I've been looking at  the following snippet just
>wondering what happens in the case where the present
>bit is 0 and p10,p11 predicates are not set anotherwords
>they retain their application values. Would this not
>cause an errant insertion if either p10 or p11 were
>true in the application prior to the VHPT handler?

>(p7)    tbit.nz.unc p10,p11=r19,32              // is it an instruction

tbit.xx.unc sets both predicates to 0 if the controlling predicate is
false.  See the 'else' clause on page 3:229 of Document Number:
245319-004 (ia64 Volume 3: Instruction Set Reference).

