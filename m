From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Sun, 09 Jan 2005 17:21:05 +0000
Subject: Re: INIT handler modification
Message-Id: <200501091721.j09HL52j046728@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41DE990B.702@Ext.Bull.Net>
In-Reply-To: <41DE990B.702@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net> wrote:
> 
> The limitations on slave INIT and MCA handlers are mainly due to the
> lack of kernel stacks to handle these events.  Russ Anderson (SGI) is
> working on patches that add per cpu stacks for MCA and INIT.  Once
> those patches are in the base kernel, we will be changing the INIT and
> MCA slave handlers to use the multiple stacks.  That will give us real
> processing for the slave events.

Tony has put the patches in his test-2.6.11 tree.  Those patches should
have enough support to allow the INIT and MCA slave handlers to use
the multiple stacks.  

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
