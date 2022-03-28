From: Kalle Valo <kvalo@kernel.org>
Date: Mon, 28 Mar 2022 12:31:14 +0000
Subject: Re: [PATCH 00/22] Replace comments with C99 initializers
Message-Id: <87bkxqz2b1.fsf@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
        <8f9271b6-0381-70a9-f0c2-595b2235866a@stuerz.xyz>
        <87fsn2zaix.fsf@kernel.org>
        <cc104272-d79a-41e1-f4de-cb78fb073991@stuerz.xyz>
In-Reply-To: <cc104272-d79a-41e1-f4de-cb78fb073991@stuerz.xyz> ("Benjamin
        \=\?utf-8\?Q\?St\=C3\=BCrz\=22's\?\= message of "Mon, 28 Mar 2022 13:51:42 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Benjamin =?utf-8?Q?St=C3=BCrz?= <benni@stuerz.xyz>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

Benjamin Stürz <benni@stuerz.xyz> writes:

> On 28.03.22 11:33, Kalle Valo wrote:
>> Benjamin Stürz <benni@stuerz.xyz> writes:
>> 
>>> This patch series replaces comments with C99's designated initializers
>>> in a few places. It also adds some enum initializers. This is my first
>>> time contributing to the Linux kernel, therefore I'm probably doing a
>>> lot of things the wrong way. I'm sorry for that.
>> 
>> Just a small tip: If you are new, start with something small and learn
>> from that. Don't do a controversial big patchset spanning multiple
>> subsystems, that's the hard way to learn things. First submit one patch
>> at a time to one subsystem and gain understanding of the process that
>> way.
>
> I actually thought this would be such simple thing.

If there are 22 patches and a dozen different subsystems it's far from
simple, as you noticed from your replies :)

> Do you know of any good thing where to start? I already looked into
> drivers/staging/*/TODO and didn't found something for me personally.

I work in wireless and one my annoyance is use of BUG_ON() in wireless
drivers. There just isn't a good reason to crash the whole system when
there's a bug in a wireless driver or firmware. You can get list like
this:

git grep BUG_ON drivers/net/wireless/ | grep -v BUILD_BUG_ON

It might not be always trivial to fix BUG_ON() usage, so it would be a
good challenge as well. See the wiki link below how to submit wireless
patches. But just send a one patch first, don't work for several hours
and then submit a big set of patches.

We also might have a todo list somewhere in the wiki, but don't know how
to up-to-date it is.

> Should I drop this patchset and start with something different? 

Like Mauro suggested, splitting the patchset per subsystem is a very
good idea. And first try out with one subsystem, and after seeing how it
goes (if they are accepted or rejected), decide if you send more patches
to other subsystems.

> If yes, what would the proper way to drop it? Just announcing, that
> this is going nowhere in a separate patch?

Replying to Mauro's email and telling your intentions is a good way to
inform everyone.

-- 
https://patchwork.kernel.org/project/linux-wireless/list/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
