From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 19 Nov 2003 12:42:44 +0000
Subject: Latest 2.6 IA64 Baseline (Mosberger) testing report (Boot hang)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3AE9A.A0C23028"
Message-Id: <marc-linux-ia64-106924591531123@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863716316469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863716316469@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3AE9A.A0C23028
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

ACPI Test Report  for 2.6 ia64 kernel=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=

Hardware Configuration:
-----------------------
System Name: ACPI-LION
System Type: 4 way 800M Itanium, Lion
M/B revision: N/A
Processor version: N/A
Firmware Versions: N/A
I/O configuration summary:
	QLogic QLA12160, Seagate ST39205LC boot drive
	IDE floppy and CDROM
	Serial console
	PS/2 keyboard and mouse
	USB mouse
	Ethernet Pro 100

Software Configuration:
-----------------------
	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.5 on 11/19 =
(Shanghai time)
	2.bk pull from http://linux-acpi.bkbits.net/linux-acpi-test-2.6.0 on =
11/19 (Shanghai time)
	Successfully automerged by bk without out any manually work.

	3. patch from http://bugzilla.kernel.org/show_bug.cgi?id=3D1533 to =
solve  kernel unaligned access when pressing power button


ACPI Features Tested: (prioritized).
--------------------
1. Boot 				tested ok
2. serial console			tested ok
3. PS/2 keyboard			only work for a few minutes, then hang
4. ATI (run X window system)		tested ok
5. PS/2 mouse				tested ok
6. USB mouse				tested ok
7. NIC (eg. Ping or ftp)		tested ok
8. IDE (eg. r/w floppy or CDROM)	tested ok
9. SCI (eg. Press power button)		tested ok
10. Soft Power off				tested ok

           CPU0       CPU1       CPU2       CPU3
 29:          0          0          0          0          LSAPIC  =
cmc_poll
 30:          0          0          0          0  IO-SAPIC-level  =
cpe_hndlr
 31:          0          0          0          0          LSAPIC  =
cmc_hndlr
 32:        724          4         32          0   IO-SAPIC-edge  i8042
 33:        493          0          9          0   IO-SAPIC-edge  ide1
 34:         34          0          4          0   IO-SAPIC-edge  ide0
 36:        777         31         46          0   IO-SAPIC-edge  i8042
 39:          2          0          0          0  IO-SAPIC-level  acpi
 44:         16          0          3          0   IO-SAPIC-edge  serial
 45:         14          0          3          0   IO-SAPIC-edge  serial
 54:       1656          9         78          2  IO-SAPIC-level  =
uhci_hcd
 55:       1032          5         55          1  IO-SAPIC-level  eth0
 61:       5520         13        279          1  IO-SAPIC-level  =
qla1280
232:          0          0          0          0          LSAPIC  =
mca_rdzv
238:          0          0          0          0          LSAPIC  =
perfmon
239:     354543     349871     349425     348988          LSAPIC  timer
240:          0          0          0          0          LSAPIC  =
mca_wkup
254:        154        126        218        183          LSAPIC  IPI
NMI:          0          0          0          0
ERR:          0

Problems:

1. PS/2 keyboard	only work for a few minutes, then hang.

2.alloc 0x0-0xcf7 from PCI IO for PCI Bus 0000:00 failed. (known issue)

3.ACPI: No IRQ known for interrupt pin B of device 0000:00:03.3. (Known =
issue)

 <<dmesg.26.ZIP>>  <<2.6.config.ZIP>>  <<lspci.26.ZIP>>=20
Thanks,
Luming



------_=_NextPart_001_01C3AE9A.A0C23028
Content-Type: application/x-zip-compressed;
	name="dmesg.26.ZIP"
Content-Transfer-Encoding: base64
Content-Description: dmesg.26.ZIP
Content-Disposition: attachment;
	filename="dmesg.26.ZIP"

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
OgAAADYUAAAAAA==

------_=_NextPart_001_01C3AE9A.A0C23028
Content-Type: application/x-zip-compressed;
	name="2.6.config.ZIP"
Content-Transfer-Encoding: base64
Content-Description: 2.6.config.ZIP
Content-Disposition: attachment;
	filename="2.6.config.ZIP"

UEsDBBQAAAAIAPqkcy81suX1vxQAAHdRAAAOAAAAMl82X2NvbmZpZy5UWFSNPFtz4jrS71s1/8G1
+7BzqvacxEAIbNU8CFkGHXwbSyZkXlxMcBJ2CM7H5ZzJv/9asgHJSGYe5kJ3q9WSWn2T5E//+Nen
f/zLQYd9+bbYr54W6/WH81Jsiu1iXyydt8WPwnkqN8+rl/86y3Lz771TLFf7T6LVp6opLpcF0O0P
29X+w1kXfxVrp3zfr8rNTlLgOPLpOCfzhKQ0JBFHwZePExgHBEU5jsOEBkSBM44iDwVxJIF1V2Mp
19rZFfvDu8qcPaBEbfzIZjTBCmTEvDxJY0wYyxHGXCfGXBUpiIE+83M2oT7/4vblICsUnVb/cVY7
Z1PuhSAKloQj4nnE07A1boqCgD2GTOnHzziZK79JEgeqHDRmeEK8PIrjxABGzAD0CPICqk1aUC6W
i+9rWKNyeYB/dof393K7V6cvjL0sICq/CpJnURAj7xLuxyk2YOMRiwPCiSBLUBrqDWckZTSO1G6m
AFZETbblU7HblVtn//FeOIvN0nkuhGYVmipR1O8pTPq9EVUXNAwz5Vf6wEiYz/FkjDyYtGAcp5RP
VNE4aGVOI05SWADEQUR1YkEPaSbJT+sc4imNAvJo1gIhXT4mEWg7NmmCxHt0rLGUwEmSMxq2cAWC
b3O3hYCNac6iTgtFgsYEevlG8t509Et0gwadmcrtT0eXIzrj+83uajKEE6pMt/iZE/8CVC1PCrqV
NlFTkkYkyCuQunJCgFEawLbMdMmqJQWbwAnMeEIw9VuWKnBzjGBz1fagf8JGWYiU/jzK4H+cjkOi
ateMpjxDQQ7QPNSslOQeYpVHoraEPY0SqlqxatuFaJ5/A8MYpx7MhjtQhjbJxoQHI3WVx5ZVviR1
f520c9cPjct5SdrvhbpiGDpuMmsbz6+Tur9OCuNp1fIgp57unsJEGxSoJgkTbmbR7eQsS5I4Va2U
cHlIBYB79EPd9tSd08iPL/cWqxCmLmED5TOUqpY2SnOcZEy6sxo0guYhz0ngK3Q1MARlVgyz2GjO
Z7T8a7F5gqgAy4DgACECeHlpppPy72Lr0M2+2D4vnorfHHbpZeRuHcWxOugKlnGuDVxCfXQBqj14
fGED+ISkoRZXSHBjh0qYR0bZ+FICdtFX/HBpaxJ8YZkgfOBE9w8SnpIAzYWbDgPTEumc4FfuxSGi
mncU0ICMEX6UI29gIhRqLnsS8ySohnZ0p5g6k3L/vj68aOtx3ghVE8FOk/HUPsQU3eDFdjk67LTA
4az4ksbYegGh2hqCQdHI0hilYleYWstQb/XkeNvVX6BZsRJQnpr7D7kIQEhqYhAWb+X2w+HF0+um
XJcvH45X/LWC8ML5HHLvN50TQIxDEDMn1Xu9+LAMIUpMLUfr8umHs6x61FuMgiko4Sz39S41PE6+
5h5qx2MKsWwbkejEQ3jYv22nycA1mVT0iA/q+POiIU4fEx4LdHsH0cgYEh/RKVK9ngKVtvlL73bY
v8DSiPJUDR0RRzfwJ6E3oR/epEFginOpRww91dDTmheLHUTJReF45dPhrdjspZm7WS2LP/Y/984z
hKevxfr9ZrV5Lh2wf9DeWQo11YJUhTtEBlPVrFeQPMwCTkVgTAxIxtN4apEWe2Y4DN/Swg/iJHk0
4xhmVBcg5wgkoLGeFh0RPiRqgFSmTEzA0+vqHRb3OOs33w8vz6uf1inRzV8FgAALpcA6/WoQNPb9
UYxS08jrWNvUKOG033HN4/ZCdLTCFxpbo2W8ZdmmZw45ynh8leiBJm2bAHmVq7oQBRHc78zn7TsM
QgH3bt69QhR6971rnHDo9XtXaHhK/YBcY/Q46OD+8IpMmN3dda7YJ0HTvUIzSXj3mtiCpt9vp2HY
7dxe6Suh9EpPERvc99y7K2w83LmFlc3joMUTaJQRebgi/uxhyq6QUBpC3HuFKMDDW3JtsngadoZX
JmtGEejBvKF2xu2mqX+9c+jMlqRWePvWE9gojpqhzaVWGD0/JYQ4bnfYcz77q23xAH9+O9o257Na
y2pEEqKhbGdi2onrkMAcSwi8oVl4WO9Xv+sNnc8pop6MTYJZ2IxmjEPyDzsRrYssxSBE3dTPmF7/
qADNsL2GikyUjYWLVnqvcZSRiFnUrCYB/2ISVDikFhEb/kr8lOFx7jPFJ0kmx8mS1aTPy9Xux3+c
/eK9+I+Dvd/TuJ63pu6rPgZP0grIDcCYaeATg9QIzGck8rTU5cRcDdpZ+VaoUwDxavHHyx8gsfO/
w4/ie/nzrIhvQjPe14UTZNGuOUd1fAGo5mylRETdAsOaKPi/qLzyC0QQj8c00gQVMq7Lv3+vSr4y
AtpaYt3uQw4mYJ5LpTWqhOwEYfDwbXiEr3Gg+N5ibFS8sLmauTkhhzYHWVF4MxRBxmflH0K6JkS8
ZM4gOm3hDBkoTDHFLSQQ9PuYW8y7pPDCedcdum0TRNrFEGhwcBabKkn8jGcQplXpagvd2OOTFjRN
2kYC8T1yG45Ym83H8K6LB7CSnaamnlHSQXheShgD1a0ibddKTHwEGwZC3LFWJWmQCZMnSfq9ixU+
EVGYmySxRY6S+KtcbbCSltxJJfKNxUmVwu0Mbi9VzsPd4d3PFv4RS7qWYnHFQNRKTCY6KvZ/l9sf
q82LyUJHhCt2QqE1HAslCE8r8lPXFSgPYQ7NsgH/gEbSspgmJovoXGMI9Pm0Ua6vUbSW9fgzqawm
RkyXCRBy70M6kKdxxhs1B5WuWRHQxKAJbcWOU4vLFJLJjs1olCa2PEUwJti2Ux/F4Vs8pcSyG2Vz
ZNnIFW+bCtNqSKLQadIhmvzXma22+8Ni7bBiK6o8Wl3xkx4bJfnMJmIyswSqkCqDDGbcKKVeIww+
rwTkuPVJg7o+FdS+K8SIQNufV+v91cFEvvC1EU9B2a0rDkRfM5LZVQIIaMLRKCBGl1RRgG5UJE2N
rnDVqNq6ACKwe9E4aBWkKmiLBZ+IOuYvkfoPkPeappJhnjTKzIaoW1GAXLTI8+YQJR/zjuGWk7ZZ
gKJ8cNtxv5rxQYBtB2yJJXYApxpYVnnesaSJAUosqY/YVh6dkdSi2QT+tWn9A4ytzX4J3j4SxSer
qREkk4fcD+IHgAClMYj/WjKRndyUW+d5sdo6/3coDgX4AH0jCF7y4NrEonYczr7Y7Y0tkykfE92w
nbHgHCgmakqAUrwp9uaiLOCac1ZjvCwMtcpZHHl1IHye8a8ZCug326TyLDKNj+xfi62Q6LN768A8
QbwTfl/tNdWWBlacbuh+KqR63WoC4cZjSFBgFoBl0ZhY1F30UGUmeRf2pUlQfliv3mEZ31brD2dT
r0pbIit48iywubpJYgnt5KI2SnKJWBhblIJCb+C6rpgiC4GHEk6wuE6S+tTmXEe9nhnhjVOjYSUE
Mk4YhK4FNdAeP5PmuE8YH9YusliPCHFGQksZIyKd6cX5zQk7cLtDbFkFgeOxLdKnbGiTlSQUWwcC
quaJMMmMnVGUpxMIDK7tB2B/3gvn1cQkopYUyQs6uolV5ryxTgICs5rYppQNugNbUXKCQoQnlpaP
JACr6NvSonTg9ofW+XZtpTQ2HQ4CarRznI7jqPvlzTKHxkmkc9s5v+95loFNaGKbrSSxZTDN/V+L
IWpp62K3c8DPOp835eb318XbdrFclQ1BhTVIkUeNRTFe/ig2TiqyCqNB520OzpZlgxk1HyY+LDbO
6ni43egJXKqpCXpb7IvD1knFyMxmEnTJOj669ZDzebV53i62xfI3MwOaNs7/avRofSj2Zbl/NTcb
GU9cKfMioP+++9jti7dGR4ATNUCjq6eb98O+pWBHoyRTE8JsV2zXonLZmFGVHJL1jBHw4WpypiHy
hKFsbkcznBIS5fMv7m2nd4Xo8ct9f9Cg+TN+rLs/z4JEcGbJOys0mZmbkZkta5DTR29icwltjEJy
cUh+VNgYrO2JQi2EQKAcN3/ndHDb61xAGUlNrXPMBx18795eIMDbJKyjLGg1gup4vT6wN6woZODN
E7wjCALk6UivmZ1Q4FCmjfPjS6I5v04TkQceG62oohRqjCV+5/VIT+xOUJE6Q2xBsSXTqQjFjNmi
spOeMeBiSwIrlYszPKl0tY1MXNoxaRh+XWwXTyInVU1l3XSmrvyMywpwrN11gmBfAZ6tpRyaOGOp
7uqmxiAeMvvVQq8O6+0HnbumitVQgygqtnFzUEVNsJdYUFGaZyjl7EvvciiSgMw5RMOWjASclSAC
oBzVxc0WnR+OU4PwAmoYmqhaDQd5wh+ZEQpNsoh/6dz1z/uug20HSUY9EGC0fim3q/3rW7UWCmay
2C7/BmfjNO/6mGhYsdmV2x2oFmQGNhlycQQUm2/ngBrq9KOMyS1jVvCvFN92cnHBwTiwJKSN3gEC
/jXyAptD3z+9LssXR1xualjcB8TxxIstl7xhN6TAN7alU7MUWVCQq+YpN9ZyxYU9QGn7y+O2mkHa
HfYtCQvkgQG1pHF+dfQFEaLzvC7f3z/kWdjRcVc79JOixWiciMjy/Cunvf5tA1RdSVaAXqpfhoPf
Ofd8S24jsOC/QsuZhECnbmdgmjOJQx6JI9G71iQct/CDUNsyregBCERhxaix4qztrViuFuaAc0ZB
lIuSdE3jrV5WezAYs9WyKJ3RtlwsnxayqnG8laYz8xrH3scVXIn7+zI+00wp2KxOffypQ/I54lyv
Yx4xSczoHIyoxTkdyRjBWUq5sXgONN2LbrvWbru/1m33Wrd/NkIF+G2oydZI4BWO5P1trU1KKJhj
QPoWZfizBTdvwYUULLYVm8ZhS9uvWdw4nDtutIzHsp02hgraa7I7apI84b7xZp5UG4PWUBYP+/1b
fQX/jAPaOI/5BoSNPmpM5vn6qbsXsxsf8ZuI2zoFrN5hyKCRDpqdic52lV9OXN1psisOy9J5Nneo
XA1QIdOjcz7vOTK77OKMS/jFApyglb6bGvIw0fqur56bYPI6ugIGP6LNbbjaPRVrSJyKEhx0c7Rn
rfBaNAz5LchJC25E2pAtuLZ2WA7RjJu1bbJJ0raLonmvBS3ehlmRmVXJjsVoaYLZpZpFp/2pAGbd
JqCnKzWAPJoSzBtFgDPe0zl4NU+VBcAs0YBE8kYBsMYFMZ6qzOXvWsDj2s1FYqiNCrKxVHtYVwHy
MdO3BgtH9mWnNkyEE3ur2ENWpHweFJJv3+IW1bfaj8V2v5JHTPzjXU+OEkgVqHgRdjr91S0wGJHo
TGTuOGb+NRIU0jG6SsRRSq8RhQhbSI4E0tyeSLThiEeS4vJxgEbE4p8r98ay0RU5ILkBacEwDvrX
RBYpzgMSN0rauw688BqriGCRLF0RbXx1FrOApzDMa4wy29of949P9Zk+ihmodj1a7CHydoLF5uWw
eClML2egwfF+ypd/rnblYHA3/N39p4aH/UHkg6Ze917v64y6b0Hd39lQAy1Bb6A6dlQLQ6sYg769
r75rR9nF6HftqJ4dZRe+37ejhjbUsGttNbRP77BrHdewZ+1rcN8cFwRwQmXyge461EauKGuYXFCD
qLkGR9Y2eHMAR3hzVY5wm+jN9TjCm9N6hDc17AhvztpJfptArk0itynSNKaDPDUBswYw475citoC
jLeL99fV085USvL1x5P+KMePI5J2bq0niaOchowb68WAg/wWafkywELE09h4Z1I0qFLshhCIPzbT
8gbairPm34CLSBwi6y1IIOhaKwmAnMWxF8eW99GAB6PukchyM0K0r57qmmIEXG52JUR+y9XuXbwF
q6olpgWbgSfHhnJp6J3gppmW1wwMZUEfYmTIbX2fpAaseFhi6syPo8ZFUQWRD34O1B4qkNtXNDIo
X8r6sw/qBaa6RRCP9feoApAHNMrmeRhHliNlhQjmyO2bxFNocJDxTqenCMXKw2apyiGPPxSC0/vU
YLU5/KzoHbR9el3tiyfxFQGtMTR9U3/ljHzNCMR4qbY/aky1QJZAAEhixkiY2e5fAMGMpKNYHB2k
EKxaCnuCznq77Pgi0lh9ki3bJQTtDqntgFcQhDxBMzu6Ll9nbv/uznZSLbgkWe/WNQ1A3FKwCo8C
ete7s+xdSfCNd7s2kyMIMOv1rZe3K3xn0NIBLJ97O20hmMbp2O24tguzQBGFnTvLVUSBhgzFet22
Qg/bWw/7dy3tJ571MjFgW42fIHgMfes9kmqFWM/qdeQEh7SVAYmY271vYVARtC0Rc4fdFhUQ+H4L
PkREXG3rmkyPwPvh4Na92P0UE/e+bdklQceSg0sCSE+Dwbxl6CyOKJ7Rke0abrWB0cD6ElASzDsd
Xcx6n8HSISdjI/v2A2SOMstdhPi92NTWlBkuB1Sn0Im4mmlqLfo1+EkAK05I9H96mf/JVPASbErT
K/CqqbjsZylSAn6EIu+BenyiuS3Z8jGC7BuLxDZOjeUB0fGk3O1FDLDflus1+H3DIbdgRibgjyfa
81wBjs3gTAErfdXn6Hi92O3MVwLMi6WhR0FGeBzzSc5toZggszsE2Qe2nGQJpPRjthuPgoDxOG0+
NFSn9PC22Jy/GHF+nT+h9et8hdeENicPIKd7JaduAZj7vk0JANu8miFHSRNOLA5Z4B9Q8zxNQ09H
HFnuU8lpEp+RgADbcq4pSOYJMp42i1mib4sX6x0nuYIeHtiMslwFjKKobZlA+dO4dQImCfwtX3tZ
hLx2NCb3GRoJUgMHeSbWq0K248M2QVYUSwjlxGt7Yx+mI2pBeCzULpaL931p2joYcUuCIdcTPVhv
k8oFJWPEMlv9GAhSHgxcW4Qk9z0bNe8aK/LL8avbXsHVlynAEAF238g/9GW/vHeiLphmWa02htOx
JaCV+yYjKXtAtsfLcipofNemnKM0mI3blDPALdzHyBub5zFYfd8uth/OtjzsVxu9pItT3FUvLyXb
8nm1br5kOnWUpLFPISMxhuRTcddy7bwunn5cXFCvPgOWokh8L+3iC0cmouOXkmqcdIf1160UcPVR
IGF88wn6hlKvcSZFmXjrkc8m5q8RyfRaHIJUX1nQxSUoDR5bM5RKKBbYTF6NT2gkzhN+hQaYEWJ7
QSQ/lSbJcZiIb7hdpaOp5dlGjW5+MaleNFY8Vd8vNIYYxtPoI8n2A+zMS1XCMTevvpOiNf5/UEsB
AhQLFAAAAAgA+qRzLzWy5fW/FAAAd1EAAA4AAAAAAAAAAQAgAAAAAAAAADJfNl9jb25maWcuVFhU
UEsFBgAAAAABAAEAPAAAAOsUAAAAAA==

------_=_NextPart_001_01C3AE9A.A0C23028
Content-Type: application/x-zip-compressed;
	name="lspci.26.ZIP"
Content-Transfer-Encoding: base64
Content-Description: lspci.26.ZIP
Content-Disposition: attachment;
	filename="lspci.26.ZIP"

UEsDBBQAAAAIAOmkcy+9ThAbNgQAAOcrAAAMAAAAbHNwY2lfMjYuVFhU7Zldb5tKEIbvI+U/zKUj
xc0uHwux1At/JA1qSNy4aS1FvljDYqODAS04PemvPwvGjh3HGNyeo9OVfZFYhJ2Zd56XHQIItZD6
AYE1aMOY++6EtcAKUxZAN+LxBzAV1VCuO9C3rKGen9Xg7BkQPjs9geJzHdBJ0oLxPIEZTVLGz2HG
XH8+A5c9Jyw4h4CmLHReAJ2enJ6gPCUGq3cFvkjFPeqUZxUnLrNCI+bRpOl7YCJ4svN0o7VaBvNx
8iIOzjYCtuAx/CuMfoRZRb7DQMOac4gAor2usi7uIY54mgBNASMk6kn8n+wjJqNXmQo8DjqiiDDl
URAwXqYzO3NbZxb38aZr/acqz8F6+AL6LrXEM5dqVWVNrQoDuzNPykTmJ7xjol+RtCFjR8lODsj1
EzoOmDvaZqWJq6BvdTdrJ6aKdBX6ggWns1m2Nv875/M4hd6ipm1mikhl3TeGZ822CDn6tWtFF4Vd
pVPGQyZk7HSSrhsX5sUlPK3OFVVnvhwVBZp7u51HuYRrUdhrxtv2HUQh2FF2YBxR7h6iZmUp/XW1
zWYRf8ngoOLjUY9lv6GhKs2xn55DGIXNmDOPpc406/5ZAU77PNrpzdWVSLRRebY8WYVs2F4L1KUx
HfuBn/pMaH9ynRH0ox+Mg01DOmEzFqbwzHjii64pS4hEQPz2qS34zWKa+pmP1lG2v1rwlTnTMAqi
iYgrqDjwIKLB8HaBTzHe7Aki2r+xJYifceyHk/0kSWlvx6hqb4m9E6W5QqnoZA9Lz6uWb8M5V3/H
NMxJPdzbb+I5ebztLUMxP+92g17FDRgJN9xE4ip7b+RqBH0aQhNMbfFtkGOFtutyliRrswQag3b3
rLi61b1eqBt4yyZeti8sN1khBLeQIoQMugNL2CbimV3XTf3lVnjZKZJbgz5WMEHQm1NR0JSGoSjs
MUg5VRchxHbliDoiXigi7ytaj7plb0HMKLU3Ifb0515vE7zDkWYNR+Lf7Eh8mCM1rcSReAnSy6Zf
1xKuTJtxMJ+UDBqNEGGe7JiYiSlz8zX9bM26g6yb/sqbB8x5hJVx+ZwvSCl7GFScJwuaohearL1g
RlU/rnph/rm9MIyyXrhu7V440vZCr90L78/thamV9cKp7QusSNuL2r7AegtJcWezEIJlEaLIIkSV
RYgmixBdFiFEFiGGHEKwLHMEyzJHsCxzBMsyR7AscwTLMkewLHMEyzJHtAPmSI+mdDNZ7zeoeDdq
BQlyPCxeCCkbhTq6y/Mpmq7dDS+WebN/rPNnoq5I1ckXFiL0CiKqB90SUOGlFlbMpTZZ7lewIo+Q
KjdexROZ777LQNhhESizBxu+8dz3YWcpyKghqF6CUheWv7tQ157+vnkFcIn2vZTKGqbKQl49kq9H
/pAh+b8krx3J1yOvy0JeP5KvR57IQp4cydcjb8hC3jiSr0r+H1BLAQIUCxQAAAAIAOmkcy+9ThAb
NgQAAOcrAAAMAAAAAAAAAAEAIAAAAAAAAABsc3BjaV8yNi5UWFRQSwUGAAAAAAEAAQA6AAAAYAQA
AAAA

------_=_NextPart_001_01C3AE9A.A0C23028--
