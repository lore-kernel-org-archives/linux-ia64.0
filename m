From: Matt_Domsch@Dell.com
Date: Fri, 27 Jul 2001 02:51:07 +0000
Subject: RE: [Linux-ia64] efi/elilo serial output
Message-Id: <marc-linux-ia64-105590693005941@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005932@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005932@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Looking for suggestions for serial out at 9600.
> 
> EFI 1.02 will allow serial out, but only at 57600.

I have all my IA-64 servers (Dell PowerEdge 7150) running serial out at
115200 (the EFI default), and linux console logging at 115200 also.  Haven't
tried running it slower though.

-Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!

