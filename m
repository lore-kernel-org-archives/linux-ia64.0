From: Matthew Wilcox <willy@debian.org>
Date: Thu, 14 Nov 2002 16:12:16 +0000
Subject: Re: [Linux-ia64] Re: memcpy failure
Message-Id: <marc-linux-ia64-105590709805431@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805424@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805424@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 14, 2002 at 10:09:34AM -0600, Mario Smarduch wrote:
> Aren't all these routines suppose to return -EFAULT if a fault occurs?

No.  Did you go to the Richard B Johnson school of C programming?

-- 
Revolutions do not require corporate support.

