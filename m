From: christoph@lameter.com
Date: Tue, 03 Aug 2004 02:33:56 +0000
Subject: Re: Timer updates revision 7 (asm sets predicates/various fixes)
Message-Id: <Pine.LNX.4.58.0408021930550.5375@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2 Aug 2004, David Mosberger wrote:

> >>>>> On Fri, 30 Jul 2004 08:30:19 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:
>
>   Christoph> On Thu, 29 Jul 2004, David Mosberger wrote:
>   >> It occurred to me now why your numbers are higher: I linked my
>   >> program statically, whereas yours is probably linked dynamically?
>
>   Christoph> Correct. But why would this have an influence?
>
> I'm just trying to determine why our numbers were different.  I dont like
> unexplained differences.

The different numbers may be due to the different kinds of scaling
applied to the clock frequency to produce the ITC frequency.

