From: Keith Owens <kaos@sgi.com>
Date: Sat, 08 Jan 2005 01:26:49 +0000
Subject: Re: INIT handler modification
Message-Id: <4479.1105147609@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <41DE990B.702@Ext.Bull.Net>
In-Reply-To: <41DE990B.702@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 07 Jan 2005 15:13:31 +0100, 
Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net> wrote:
>Here is the main point, the present code of INIT handler for slave CPUs 
>is reduced
>to (file arch/ia64/kernel/mca_asm.S) :
>______________________________
>
>GLOBAL_ENTRY(ia64_slave_init_handler)
>1:      br.sptk 1b
>END(ia64_slave_init_handler)
>______________________________

The limitations on slave INIT and MCA handlers are mainly due to the
lack of kernel stacks to handle these events.  Russ Anderson (SGI) is
working on patches that add per cpu stacks for MCA and INIT.  Once
those patches are in the base kernel, we will be changing the INIT and
MCA slave handlers to use the multiple stacks.  That will give us real
processing for the slave events.

