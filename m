From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 14 Aug 2003 21:49:06 +0000
Subject: Re: EFI boot manager fail-over behavior question
Message-Id: <marc-linux-ia64-106089806414340@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106081992104989@msgid-missing>
In-Reply-To: <marc-linux-ia64-106081992104989@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt,

> > Could somebody more familiar than me  with the boot manager 
> > clarify this?
> 
> I have heard of similar problems specifically relating to netbooting with the sample implementation.  Is the behavior correct (traverses the boot option list) if you select a different, non-netbooting option?  
> 

Yes, it seems to work when the failed session is not netbooting (tested with EFI 14.60). 

-- 
-Stephane
