From: John Baboval <baboval@mclinux.com>
Date: Fri, 04 Aug 2000 14:23:35 +0000
Subject: Re: [Linux-ia64] serial console on a lion?
Message-Id: <marc-linux-ia64-105590678205268@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205265@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205265@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There's documentation on how to do this in the EFI spec on page 320. You
need to use the "SetVariable" function. Output does go to the serial port,
but according to page 149, the output is in 16bit unicode. I've seen output
to the serial port from setting these variables, but minicom doesn't support
'Unicode ISO Latin I' so I can't verify that it's the shell prompt. Does
anyone out there know of terminal emulation software for linux that supports
Unicode?

On Thu, Aug 03, 2000 at 10:36:17PM -0400, Pat O'Rourke wrote:
> 
> I've been going through the EFI documentation and it seems possible that
> you can redirect the shell's input / output to a serial port.  However the
> steps for doing so are not clear to me.
> 
> Any suggestions would be greatly appreciated.
> 
> Thanks,
> 
> Pat
> 
> -- 
> Patrick O'Rourke
> orourke@missioncriticallinux.com
> 
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 


