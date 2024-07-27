import SwiftUI

struct EmojiPickerView: View {
    // 预定义的表情列表
    let emojis = ["😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙃", "😉", "😊", "😇", "🥰", "😍", "🤩", "😘", "😗", "😚", "😙", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "🤥", "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "😎", "🤓", "🧐", "😕", "😟", "🙁", "☹️", "😮", "😯", "😲", "😳", "🥺", "😦", "😧", "😨", "😰", "😥", "😢", "😭", "😱", "😖", "😣", "😞", "😓", "😩", "😫", "🥱", "😤", "😡", "😠", "🤬", "😈", "👿", "💀", "☠️", "💩", "🤡", "👹", "👺", "👻", "👽", "👾", "🤖", "😺", "😸", "😹", "😻", "😼", "😽", "🙀", "😿", "😾"]
    
    var body: some View {
        VStack {
            // 搜索栏
            /*
             TextField("搜索表情", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
             */

            // 表情网格
            let columns = Array(repeating: GridItem(.flexible()), count: 8) // 调整列数以匹配设计
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(emojis, id: \.self) { emoji in
                        Text(emoji)
                            .font(.largeTitle)
                            .padding(8)
                    }
                }
                .padding(.horizontal)
            }

            // 底部导航栏
            HStack {
                Spacer()
                Image(systemName: "gear")
                Spacer()
                Image(systemName: "gear")
                Spacer()
                Image(systemName: "gear")
                Spacer()
                Image(systemName: "gear")
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.2)) // 设置背景颜色和透明度
        }
    }
}

struct EmojiPickerView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPickerView()
    }
}
