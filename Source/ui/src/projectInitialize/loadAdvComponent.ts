/*
 * @Author: LPY
 * @Date: 2025-05-30 10:54:44
 * @LastEditors: LPY
 * @LastEditTime: 2025-08-26 16:20:24
 * @FilePath: \glkvm-cloud\web-ui\src\projectInitialize\loadAdvComponent.ts
 * @Description: 加载Ant 组件
 */
import { 
    ConfigProvider,
    Button,
    Pagination,
    Dropdown,
    Menu,
    Form,
    Input,
    Tooltip,
    Checkbox,
    Progress,
    Switch,
    Divider,
    Carousel,
    InputNumber,
    Upload,
    Select,
    Tabs,
} from 'ant-design-vue'

export default function (app: any) {
    app.use(ConfigProvider)
    app.use(Button)
    app.use(Pagination)
    app.use(Dropdown)
    app.use(Menu)
    app.use(Form)
    app.use(Input)
    app.use(Tooltip)
    app.use(Checkbox)
    app.use(Progress)
    app.use(Switch)
    app.use(Divider)
    app.use(Carousel)
    app.use(InputNumber)
    app.use(Upload)
    app.use(Select)
    app.use(Tabs)
}