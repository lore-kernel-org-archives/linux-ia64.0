From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 09 Oct 2003 13:53:34 +0000
Subject: Re: user-space unaligned accesses
Message-Id: <marc-linux-ia64-106570787418254@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106562414203331@msgid-missing>
In-Reply-To: <marc-linux-ia64-106562414203331@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 08 October 2003 5:36 pm, David Mosberger wrote:
>   Bjorn> The Red Hat concern was specifically about writing to the
>   Bjorn> user tty.
> 
> There are users (other than me ;-) that find the messages helpful.  If
> there is something wrong about the current printing code, I'd rather
> fix that instead (and as Grant pointed out, if someone doesn't like
> the message, prctl can be used to turn it off).  The mail you
> forwarded was unclear on whether there was a real security/correctness
> bug.  If there is, please ask for/provide details.

I did ask Red Hat to post the patch themselves.  I just posted it to
make sure it didn't get completely dropped when I cleaned out my inbox.
Perhaps this will provide an opening for them to give more details :-)

Bjorn

