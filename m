From: Matt_Domsch@Dell.com
Date: Fri, 22 Jun 2001 16:22:06 +0000
Subject: RE: [Linux-ia64] console blanking
Message-Id: <marc-linux-ia64-105590693005750@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005748@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005748@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Can anyone tell me how to keep the console screen from 
> blanking? I have had
> the system dump into the kernel debugger after the console 
> went blank and it does not unblank. Makes it hard to debug.

setterm -powersave off -powerdown 0 -blank 0

-Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux



