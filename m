From: Matthew Wilcox <willy@debian.org>
Date: Fri, 15 Nov 2002 13:04:07 +0000
Subject: Re: [Linux-ia64] Re: memcpy failure
Message-Id: <marc-linux-ia64-105590709805450@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805424@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805424@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 15, 2002 at 11:32:10AM +0100, Christian Cotte-Barrot wrote:
> On bad return from memcpy the concerned device driver loggs warning
> in /var/log/messages and the system administrator may have some doubt
> about the good working of the device.

_what_ bad return from memcpy?!  memcpy returns the pointer that was
passed to it.  What are you going to check for?

-- 
Revolutions do not require corporate support.

