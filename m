From: Helge Deller <deller@gmx.de>
Date: Thu, 11 May 2023 17:02:19 +0000
Subject: Re: [PATCH v6 1/6] fbdev/matrox: Remove trailing whitespaces
Message-Id: <1c7ca6d3-76d7-047b-42ac-716e12946f90@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510110557.14343-1-tzimmermann@suse.de>
 <20230510110557.14343-2-tzimmermann@suse.de>
 <0e13efbf-9a48-6e70-fdf3-8290f28c6dc7@189.cn>
 <a2315b9a-0747-1f0f-1f0a-1c6773931db4@suse.de>
 <15fe1489-f0fa-bbf6-ec08-a270bd4f1559@gmx.de>
 <e7bd021c-1a6b-6e47-143a-36ae2fd2fe6b@suse.de>
In-Reply-To: <e7bd021c-1a6b-6e47-143a-36ae2fd2fe6b@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, Sui Jingfeng <15330273260@189.cn>, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, arnd@arndb.de, sam@ravnborg.org
Cc: linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

On 5/11/23 16:27, Thomas Zimmermann wrote:
>>> But the work I do within fbdev is mostly for improving DRM.
>>
>> Sure.
>>
>>> For the
>>> other issues in this file, I don't think that matroxfb should even be
>>> around any longer. Fbdev has been deprecated for a long time. But a
>>> small number of drivers are still in use and we still need its
>>> framebuffer console. So someone should either put significant effort
>>> into maintaining fbdev, or it should be phased out. But neither is
>>> happening.
>>
>> You're wrong.
>

> I'm not. I don't claim that these drivers are all broken. But fbdev
> as a whole is bit-rotting and no one attempts to address this. There
> are several recent examples of this:
>
> * I recently send out a 100-patches series to improve parameter
> parsing and avoid memory leaks. That got shot down. I didn't attempt
> to support parameter parsing for module builds.

Your work is appreciated and it wasn't shot down, but it wasn't perfect either.

> * There's been a 15-yrs old bug in fbdev's read/write where they
> return an incorrect value.

?

> * See the other discussion on this patchset on the state of hitfb.
>
> * The fbdev code I recently cleaned up had bugs in how it uses some
> of fbdev's basic building blocks (see the screen_base/screen_buffer
> confusion).

As you said... some (little-used/outdated) drivers may have issues
which of course show up if one starts to clean up, as you do.
On a per-driver basis it can make sense to drop a specific driver.

> * <asm-generic/fb.h> has been in the tree since 2009 and no one
> attempted to include it until now.
>
> None of this is a sign of good maintenance.
> As I've worked on DRM's fbdev emulation a lot, I try to be a good
> kernel citizen and clean up in fbdev as well when I see a problem.> But I'd really like to see most of these drivers being moved into
> staging and deleted soon afterwards. Users will complain about those
> drivers that are really still required. Those might be worth to spend
> effort on.

I'd really like to see a way forward and get the required drivers over to
DRM, e.g. based on your simpledrm driver.
If there is a way to get basic on-screen 2D bitblt and fillrect support,
it would drop the need for most of the fbdev drivers.
The current way of bitblt'ing from a buffer on regular basis istoo slow for such older cards. Even on new hardware in emulators there
is a big slowdown visible.

>> You don't mention that for most older machines DRM isn't an
>> acceptable way to go due to it's limitations, e.g. it's low-speed
>> due to missing 2D-acceleration for older cards and and it's
>> incapability to change screen resolution at runtime (just to name
>> two of the bigger limitations here).
>
> You can change resolution at runtime; just not through fbdev ioctls.
> There's no technical limitation here. No one found any use for this,
> so it's not there.

fbdev drivers would need that when ported to DRM.
>> So, unless we somehow find a good way to move such drivers over to
>> DRM (with a set of minimal 2D acceleration), they are still
>> important.
>
> 2d acceleration is mostly useful for the framebuffer console.

and X11

> You can
> do that with DRM and drivers have (nouveau). It just didn't make a
> meaningful difference in most cases.

if nouveau got it, can't it be done for simpledrm in a generic way too?

>> Actually, I just did test matroxfb and pm2fb successfully a few
>> days back, and they worked. For some smaller issues I've prepared
>> patches, which are on hold due conflicts with your latest
>> file-move-around- and whitespace-changes which are partly in
>> drm-misc. And I do have some upcoming additional patches for
>> console support.

Helge
