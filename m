From: Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net>
Date: Fri, 15 Nov 2002 13:51:36 +0000
Subject: Re: [Linux-ia64] Re: memcpy failure
Message-Id: <marc-linux-ia64-105590709805451@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805424@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805424@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Wilcox wrote:
> 
> On Fri, Nov 15, 2002 at 11:32:10AM +0100, Christian Cotte-Barrot wrote:
> > On bad return from memcpy the concerned device driver loggs warning
> > in /var/log/messages and the system administrator may have some doubt
> > about the good working of the device.
> 
> _what_ bad return from memcpy?!  memcpy returns the pointer that was
> passed to it.  What are you going to check for?
> 

Simply, bad return is whatever is not equal to the dest pointer:
  if ((memcpy(rptr, ch->rxptr + tail, dataToRead)) != rptr)
    ...

