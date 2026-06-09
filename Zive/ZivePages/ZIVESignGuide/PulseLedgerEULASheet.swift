import SwiftUI

struct PulseLedgerEULASheet: View {
    @AppStorage("qeixbgBriwyAgreeEULA") var qeixbgBriwyAgreeEULA = false
    @Binding var pulseLedgerEULAIsPresented: Bool
    @State private var pulseLedgerEULAHasRead = false

    var body: some View {
        GeometryReader { pulseLedgerEULAGeometry in
            ZStack(alignment: .bottom) {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        pulseLedgerEULAIsPresented = false
                    }

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            Text(pulseLedgerEULATitle)
                                .font(ZiveStyle.FontBook.regular(19))
                                .foregroundStyle(ZiveStyle.ColorPalette.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(pulseLedgerEULABody)
                                .font(ZiveStyle.FontBook.regular(15))
                                .foregroundStyle(ZiveStyle.ColorPalette.textPrimary.opacity(0.92))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        .padding(.bottom, 14)
                    }
                    .frame(maxHeight: 390)
                    .padding(.top, 10)

                    HStack(spacing: 8) {
                        Button {
                            pulseLedgerEULAHasRead.toggle()
                        } label: {
                            Circle()
                                .fill(
                                    pulseLedgerEULAHasRead
                                    ? LinearGradient(
                                        colors: [
                                            ZiveStyle.ColorPalette.brandPink,
                                            ZiveStyle.ColorPalette.brandOrange
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.black.opacity(0.08), Color.black.opacity(0.08)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 20, height: 20)
                                .overlay {
                                    if pulseLedgerEULAHasRead {
                                        Circle()
                                            .fill(Color.white.opacity(0.55))
                                            .frame(width: 8, height: 8)
                                            .blur(radius: 10)
                                    }
                                }
                    }
                    .buttonStyle(.plain)
                        Text(pulseLedgerEULAReadAgreementText)
                            .font(ZiveStyle.FontBook.regular(14))
                            .foregroundStyle(ZiveStyle.ColorPalette.textPrimary.opacity(0.92))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    HStack(spacing: 14) {
                        Button(pulseLedgerEULACancelText) {
                            pulseLedgerEULAIsPresented = false
                        }
                        .buttonStyle(.plain)
                        .font(ZiveStyle.FontBook.regular(16))
                        .foregroundStyle(ZiveStyle.ColorPalette.textPrimary.opacity(0.65))
                        Button(action: {
                            if pulseLedgerEULAHasRead {
                                qeixbgBriwyAgreeEULA = true
                                pulseLedgerEULAIsPresented = false
                            }
                            
                        }) {
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(colors: [
                                        Color(red: 1, green: 244/255, blue: 235/255),
                                        Color(red: 1, green: 199/255, blue: 220/255)
                                    ], startPoint: .trailing, endPoint: .leading))
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(colors: [
                                        ZiveStyle.ColorPalette.brandOrange,
                                        ZiveStyle.ColorPalette.brandPink
                                    ], startPoint: .trailing, endPoint: .leading))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .blur(radius: 4)
                                Text(pulseLedgerEULAAgreeText)
                                    .font(ZiveStyle.FontBook.boldItalic(20))
                                    .foregroundStyle(Color(red: 1, green: 235/255, blue: 235/255))
                            }.frame(height: 53)
                            .opacity(pulseLedgerEULAHasRead ? 1 : 0.55)
                            .allowsHitTesting(pulseLedgerEULAHasRead)
                        }
                        

                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 24 + pulseLedgerEULAGeometry.safeAreaInsets.bottom)
                }
                .frame(maxWidth: .infinity)
                .background(
                    ZStack(alignment: .top) {
                        Color.white
                        Image("ZIVECardBg")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 295)
                    }
                )
                .clipShape(ZiveTopRoundedCornerShape(ziveTopRoundedCornerRadius: 20))
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }.ignoresSafeArea()
    }

    private var pulseLedgerEULATitle: String {
        "a31dbe37915c2d465e5ba8a4e177ce3737e6d1bef28b3fa61b8536ac303d544032cf100d24e86d4ef935d7f30d2023b83c0a2d1407cb0ff44135c525b98485b3ec3a408e22fc6b06b103178d277915ccf1eb5422079ca4e4155fa1339b757321".grooveCipherAESDecrypt()
    }

    private var pulseLedgerEULABody: String {
        "1d3198fdcf85259b19ecbd0c594e2ffb439c1f458c1b132f9802cde10156c9a3fc99b44b5100ea2fc64d0f06473f39acbee1c9cbd83d4a5b049ba6439b868113720c82359d463d3e2c458a9380ed7e1ea472fd1c5c5dcecdb4d57af59a9c0ee1f22834a61d924792bba546abc8094cb7c5f2b63a840a0f9d865b1bef7a5a46bd80188c48b76b0e14c41d5f89f200168ffc2d496ebfeb9cdfa1c3701b80a0b9d027aae3ce8607ac104e31c647a7b192986d911dcc5a3a1d93ac9f8b4089465edfad62af04071023933620b96107da37b9ee577e24cdb8b277f79a526f9679f4e5fbc86732ad0eb99a9c281748881d8fb2565835eccde80a8ffe9482333819489b25362a757087dbf7c29f2197f19f1ff57b6e54b251670497339127b57f2633efe66c3d38fa62dd20a310b692ee6d522c0b1c6b71cd4736ccc88df17c131a8ca43c69901c5195e0d146adf584f9286175590790eee92de9b6df2bdab84eac68b812350439743cbea23c8ea780f40dc285363be6837e8c80205cc504bed6fb71d8cf3b1b05045f8e0e5c6a56b8b7668e261643f32382b060261b8c69a5c4a355c654aa1a0da5f0b0ea287a50944e59abe5cc542672ef68c9ad92783324d9ef1f104e32b3bdde0cec13b4c4a76c6f037d766832114026fc1cd1c86244250e66aaec5eeaed9ba8a52f4bb710a2597ccba9ece8fac491c29c42c997d745c9954da5ab9837014f3d4e192db17e92de6a87d4c5da349766a4f531e75234c17a323b7bd8a3568035b41a6455846d87919d549260dec8e2e3e9f2a95f3c8a1ba37eceffc090b70d676afe763f93cf201be1a0f6247ac9d67c3053ca0010af5617349aa6b2734262823fd90730560d40852ae2dcb323da3128f6631495ecf3da68a5d1411f94414a291243cd2eae6f3282481f6831dd5504ace33a12aaf43989a548870c9ca8d268078101e69cd9dd0a7fd130b71ee85870a61b779294f561b3f78edeabae82c312dd22f12178fd6f583c0c49a0a6ccd3a093ec5508b8339d9c4f8a573c208f7a13f1c59a95e188ad2ba8e396b47bd9a1215001ad33ff02ea6faae0e4a312e51ee8308648fcc3524191552ba857c1e3d9f0933f63d6ad36eb1262ec8378bf6cd635b87aa3d34ceecff51421e6924d56f06e859fc289ee49c92d26457f14000e2acd3bcbd03676b8a47b050dbba112bb9970bac6122f4d410838a3c0230fb11cc8ed5cdae404d33bcd2498a58545922149d5d61d5ae91da02d869fb2a6a1a3d696813643af6d593d59081c718bfc196e2f1862494b904929c2aee0ca7f5259355e68b08012a159c87ff390e216993ec5bf9a2f0ea1ff82a5ece121b0160f513498a8a08e81453f85777a26d99776e299627dde98f30c8bf0da37399dee18d2591b7931f70550b1b47e35c8b50c8fa58521c3288d03c4843f916f6ca85ddc057c055bacb90aa6395d75bf1ec2632f21485995527d69ef2a3bb10502777d56fa203dc82507eff8dad41a2db19a63fa7e5adfac69dc0e4c08b396c669d1675b8dbb9672e67bb170f3d5d1910797a1d48ec2b2fc1661ae31e3976c4ae44e2f3a6f19267a839d0bb42ec90dead81365432e00aa7c9d8d2517e206ab8717bd5f5ba79475341ae778049e3938688a8737b35de5c2062505fc1bb6239b97238da6bff995974346cab8143d13d75c09580e168d7976007c9db55671bbad2d3f17907bba01f10e980e0fd725ea103dafb5cec5d4b974542e719281e07e5ee33d5d16c3cbcf36131321530a7c0a652a7ed3ea14af514c7a79908511f14c8b0fb97f58e90f9af124e2a485e2029ebb20367fd3da56f8f3f02d2aa8c471ae37b4816c1b43dd03324138ef5d71eade662cca9e8dc9002d5971c6db2ff2ccaa3321c11ebf33f1cad7bebf45fd9ed4f53666b400cd6aae8840aefb718068da2ef3573691a58a96f07b7460badc127d2464d5d251763ed53f845aa6d059016c9a72a9335b4580a283e5de14d7f583026ea04ce250c392aa04742388685850675c53a082633b7ba4b05191ecd58390bdbbdd77fab406070cd8b6ea29f6f43fa3774ae160f33673059adfacd74a352257ad16e027a487cb47b67a8465778d6e6d48767de84b53c3eda999652cc14bd9a8bd0d53ee01c7772d3773ff79b2898b9e66027999afbb782cac8bba2273268842dfad50ba5e33a8f3c5b66db1d53be52ce62d2bd8a871bdb4934724367acc207e2a9ec5050213f56e997b80fc2e8f95301545deb8e84985111a76b334b6931ccf00f120e1260490dfae2adf44cfd291843c5a56674a42ffd2ced0760804a3b3bbe61bfb5328909997b56b939da7df35fa46420ebedeca195c799aad563f211f6bf4b8445dfed573cb26771ac13720d0967275bd784a2dc04ae97600188dd4f66922160adfc8ff5a715299f4c4e6d14d5a3ee8c8932f1649802a615a6ba7ebc53f2a05587bea80114172634154d8b097c615ba29c266e71cf742101f8141309d97ca619265969eea43b262830788fa1d87fffe43e5922abcec705ef550efc7530aa3e8b7f9fb2e6979d1735eee401bc057098c67ed4957c2e2d3ec7ddba857079a224fb8a471ee18f0df9bcc9a452540d8f5dc1909095d68f90b692b2be020a47e72be89b3b33028fc0ef936928ca5219c04af892fbabc87500bdcf816971f9e6b6852f07f489ce1958fcad14d6a00e95373925d438b9a47008a708947b1c0477ffa80cd432f34edfb61ad7f400d0cb828c0dca3e7d021f297216836a714371760e98698e9495ddd2bdc819a18437dd4a2fd8798be3d6584c2b2fcab36d4b34c1146ee3122e284b3181b3a41d0ec108cf2344d5706aee51725992cfc7d95cb8c7c4262a0658c26d5ab1d2ab056f9ac68f78ff31bdfeea4e0a74f4d666ede7d470c5a8109d7f2fb6e18e5cc32c0a1ea8da5c64ef78aad1a077a236b46e897140b528f59e9d8ceb7858a6568c634cb7942e8761490cf79f2a9cff076826e7ba2f1e91d8a5dbbc8eccff4f1dc52c1af78d4d128db4f0bb2df58be2551ec93923834c4733521e42f5ab4ed346171fc2d092d67201fcdc7dc9a1310aa853710b0c52ffca330c47fca73c4dd9e9a3d84f945d831b6e8536a0ac3c527f7b238b6fc00da149a1e98a7ec26f265709dd43a1022f12d4fd078ccc13d8e7c5b4fbf17e0cf3df29b0e1d9b2642b9dbeab0fee750967825ce0fdc4e4773850898b07ab048e796a0d7c969912e1ecd5a4d67a9c111938ff0dbbab46b85e47d14f019ddecd553d4552ea03e609a1a81a5960c3b497d3428ec6560d0ec0430148e77f2980028171019d7e55d5e3e8bc2f9f8a2fddf1a5da6553eb0a9be62ebfb177d771cdfb2132d8a0c0313fb66858517cc2577b1bd4da9c7941d4b0c8fd64b28fdc3925b0b31eac7bc84cccf2f9d7c6393bf91a7e99741f81c6d25adece34d00945a8be38b856126c82db23cd92be740230b6562c816c2cfa2fe6b30008b85b6369bd898c140784bdf55a8f42082a0a108fede8252f1ea5f532ac37f74bdfa7813508b885bc87f01a3636cec5d1b118a568d5dbb66292f67aaf25591057fa070556d308179acbd0797cc7c5996755af2b52f960d6adc29ab3b43636be9d2c7bc810ecfb3c1c71dc682675d03a168f9a75f0c26d67b21f24695050e8be44b562460479a838b801983b05958c98299b5c6a202c0c7043a0d3db3a19c963e5cb3b27e54c030d206c164346f7a9885f074305dff5a574cd70ed47243e0eaf68fc0b5546ce6a0629bb2a51844a2cbd5dc862be81cb724b5ea37baf79d57f27529846b26c1cf74b38f819d9e9243fa3345f0fb".grooveCipherAESDecrypt()
    }

    private var pulseLedgerEULAReadAgreementText: String {
        "6f861d9ab3007a04cc1357c1a5859aa9d1eb52ef7c6416c67aa5bf9987dc850cbdb856591308004afa61cd36e0c8f969".grooveCipherAESDecrypt()
    }

    private var pulseLedgerEULACancelText: String {
        "baf3bc6d146f1608c699c6a6a99ee6c1".grooveCipherAESDecrypt()
    }

    private var pulseLedgerEULAAgreeText: String {
        "b33770f0b414883c6807f78c72495ee1".grooveCipherAESDecrypt()
    }
}
