From: Chris McDermott <lcm@us.ibm.com>
Date: Mon, 07 Jan 2002 23:33:41 +0000
Subject: Re: [Linux-ia64] 2.4.17 stability on Lions
Message-Id: <marc-linux-ia64-105590698805768@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805763@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805763@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jan 07, 2002 at 13:48 -0800, David Mosberger wrote: 
> >>>>> On Mon, 07 Jan 2002 10:20:15 -0800, Michael Madore <mmadore@turbolinux.com> said:
> 
>   Michael> Hi, I am seeing frequent lockups on my Lion box running
>   Michael> 2.4.17.  I have firmware 76 installed.  Does anyone have
>   Michael> this kernel running reliably on a lion box?  If so, what
>   Michael> firmware version are you using.  I was running 2.4.9
>   Michael> previously, and that seemed to be pretty stable.
> 
> I suspect you need fw 99 or newer.  Trouble is: I don't think Intel
> has released those newer versions on Quad yet.
> 
> 	--david
> 
And from what I understand, Intel does not plan to release on QuAD,
any fw greater than 83B. FW revisions > 83B are not supported on
Intel Lions, only OEM platforms. If you install an unsupported FW
revision on a Lion, and you experience H/W problems, Intel will not
support you. Speaking from personal experience here.

Chris

