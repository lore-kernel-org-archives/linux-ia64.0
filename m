From: Mario Smarduch <cms063@email.mot.com>
Date: Thu, 13 Mar 2003 20:44:27 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806083@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> >>>>> On Wed, 12 Mar 2003 13:51:16 -0600, Mario Smarduch <cms063@email.mot.com> said:
>
>   Mario> Hi David, I'm very curious about your statement regarding
>   Mario> reproducible results - a desirable attribute for many
>   Mario> applications in our case soft real-time predictability. With
>   Mario> the caches on Itanium2 being highly associative, did you
>   Mario> notice a dramatic change in reproducibility as you did in TLB
>   Mario> efficiency? This is assuming a locked memory intensive
>   Mario> application or this was too long ago for you to remember :)
>
> Heh, I barely remember what I ate for dinner last night, so I
> certainly don't remember what that application was about... ;-)
>
> Apps with large arrays certainly can see significant variation due to
> lack of page coloring in the kernel, even with high associativity.  I
> ran a Monte Carlo simulation on this a while ago and attached the
> results below.
>
> As you can see, high associativity keeps page-coloring effects away up
> until you occupy about 1.5-2MB (out of a 3MB cache).  So if you have,
> say, a 3MB array, you'd clearly expect to see page-coloring effects.

David,
    thanks for pulling this up -  its very interesting. For 12-way associtivity
64KB pg size does stand out quite a bit from 4,8,16KB, although the effect
appears to be more visual because 32KB is not supported.

>
>
> The graph also shows that larger page sizes somewhat reduce the
> negative effets of lack of page-coloring (not entirely intuitive, but
> it's pretty complex as to what's going on, so it's not surprising that
> intuition doesn't get us very far).

yes its a very painful graph to look at :)

- Mario.

>
>
> I should update the graph for Madison some day.
>
>         --david
>
>   ------------------------------------------------------------------------
>                   Name: coll.pdf
>    coll.pdf       Type: Portable Document Format (application/pdf)
>               Encoding: base64
>            Description: coll.pdf


