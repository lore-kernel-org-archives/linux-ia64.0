From: Helge Deller <deller@gmx.de>
Date: Thu, 11 May 2023 16:23:43 +0000
Subject: Re: [PATCH v6 1/6] fbdev/matrox: Remove trailing whitespaces
Message-Id: <89099ac6-21f7-3538-8830-57baba256684@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510110557.14343-1-tzimmermann@suse.de>
 <20230510110557.14343-2-tzimmermann@suse.de>
 <0e13efbf-9a48-6e70-fdf3-8290f28c6dc7@189.cn>
 <a2315b9a-0747-1f0f-1f0a-1c6773931db4@suse.de>
 <15fe1489-f0fa-bbf6-ec08-a270bd4f1559@gmx.de>
 <CAMuHMdX8piLhEbV+pcWvdn1OEGH9N5FwDOQcqNcEjBx3=ThjXA@mail.gmail.com>
In-Reply-To: <CAMuHMdX8piLhEbV+pcWvdn1OEGH9N5FwDOQcqNcEjBx3=ThjXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Thomas Zimmermann <tzimmermann@suse.de>, Sui Jingfeng <15330273260@189.cn>, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, arnd@arndb.de, sam@ravnborg.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

On 5/11/23 15:10, Geert Uytterhoeven wrote:
> Hi Helge,
>
> On Thu, May 11, 2023 at 3:05=E2=80=AFPM Helge Deller <deller@gmx.de> wrot=
e:
>> On 5/11/23 09:55, Thomas Zimmermann wrote:
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
>>
>> You don't mention that for most older machines DRM isn't an acceptable
>> way to go due to it's limitations, e.g. it's low-speed due to missing
>> 2D-acceleration for older cards and and it's incapability to change scre=
en
>> resolution at runtime (just to name two of the bigger limitations here).
>> So, unless we somehow find a good way to move such drivers over to DRM
>> (with a set of minimal 2D acceleration), they are still important.
>
> DRM can change resolution at runtime,

Right, sure.

> just not through the fbdev API.

... and sadly the simpledrm-based drivers neither.

> Or do you mean the resolution of the text console, akin to
> "fbset <mode>"?

yes.

> I have to admit I do not know if there is a command
> line tool to do that...

Helge
