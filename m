From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 31 Oct 2003 05:09:12 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106757725200987@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, Matthias.


> I think error handling needs to be extended to not only
> recover from errors and kill for example the concerned
> application. Increasing chip density will increase the
> soft error rate, so it also becomes important to determinate
> if a error is soft (caused for example by cosmic rays)
> or if it is a true HW component failure requiring a
> replacement.

Surely, it is very important to specify where target
error comes from. I do not want to carry out advice to
replace the component, which working correctly.

> Obviously a lot of the error handling will be very
> platform dependant, but I think we should be able to come up
> with a common frame set. What do you think ?

Of course, I agree with a common frame set.
In the case of platform premising IPF, I think it is
better to regard the Intel's Chipset as the de facto
standard.


Thanks.

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>

