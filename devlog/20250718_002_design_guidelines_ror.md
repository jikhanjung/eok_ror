
# Echoes of Korea: Design Guidelines (Ruby on Rails)

## 1. Core Principles

*   **Trustworthiness:** 디자인은 신뢰를 줘야 합니다. 명확하고, 정직하며, 안정적인 느낌을 전달합니다.
*   **Clarity:** 모든 요소는 명확한 목적을 가집니다. 사용자가 쉽게 정보를 이해하고 시스템을 조작할 수 있도록 복잡성을 최소화합니다.
*   **Official Tone:** 화려함보다는 격식과 권위를 표현합니다. 학술적 또는 공공 아카이브의 톤앤매너를 유지합니다.
*   **Functionality:** 디자인은 기능에 복무합니다. 모든 시각적 결정은 사용성을 향상시키는 것을 최우선으로 합니다.

## 2. Color Palette

색상 사용을 제한하여 차분하고 전문적인 분위기를 조성합니다. Rails 프로젝트에서 Tailwind CSS를 설정할 때, `tailwind.config.js`에 아래와 같이 색상을 정의하여 사용합니다.

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        'primary': '#111827',    // 거의 검은색 (Gray 900)
        'secondary': '#374151', // 짙은 회색 (Gray 700)
        'accent': '#2563EB',     // 강조 파란색 (Blue 600)
        'muted': '#6B7280',      // 부드러운 회색 (Gray 500)
        'background': '#F9FAFB', // 매우 밝은 회색 (Gray 50)
        'surface': '#FFFFFF',    // 흰색
        'success': '#16A34A',    // 성공 초록색 (Green 600)
        'warning': '#FACC15',    // 경고 노란색 (Yellow 400)
        'danger': '#DC2626',     // 위험 빨간색 (Red 600)
      },
    },
  },
  plugins: [],
}
```

## 3. Typography

가독성을 최우선으로 합니다. 웹폰트로 `Noto Sans KR`을 사용하여 한글과 영어를 모두 일관성 있게 표현합니다.

*   **Font Family:** `Noto Sans KR` (body, headings)
*   **Body Text:** `text-base` (16px), `text-secondary`, `leading-relaxed` (편안한 줄 간격)
*   **Headings:**
    *   `H1`: `text-4xl font-bold text-primary`
    *   `H2`: `text-2xl font-bold text-primary`
    *   `H3`: `text-xl font-semibold text-primary`
*   **Labels:** `text-sm font-medium text-primary`

## 4. Layout & Spacing

일관된 간격 시스템을 사용하여 질서 있고 정돈된 레이아웃을 만듭니다. Tailwind의 4px 기반 간격 단위를 따릅니다.

*   **Admin Layout:** 2-column layout (고정된 사이드바 + 메인 콘텐츠 영역).
*   **Content Width:** 콘텐츠 영역의 최대 너비를 `max-w-7xl` (1280px)로 제한하여 가독성을 높입니다.
*   **Padding:** 카드나 섹션 주위에는 `p-6` 또는 `p-8`을 사용하여 충분한 여백을 확보합니다.

## 5. Components (with Tailwind CSS classes)

아래 HTML 예시는 Rails의 ERB 템플릿 등에서 Tailwind CSS 클래스와 함께 사용될 수 있습니다.

### Buttons

*   **Primary Action:** (저장, 업로드 등)
    ```html
    <button class="bg-accent text-white font-semibold px-4 py-2 rounded-md shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-accent">
      Primary Action
    </button>
    ```
*   **Secondary Action:** (취소 등)
    ```html
    <button class="bg-surface text-secondary font-semibold px-4 py-2 rounded-md border border-gray-300 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-accent">
      Secondary Action
    </button>
    ```
*   **Danger Action:** (삭제 등)
    ```html
    <button class="bg-danger text-white font-semibold px-4 py-2 rounded-md shadow-sm hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-danger">
      Danger Action
    </button>
    ```

### Forms

*   **Input Fields:**
    ```html
    <div>
      <label for="email" class="block text-sm font-medium text-primary">Email</label>
      <div class="mt-1">
        <input type="email" name="email" id="email" class="block w-full rounded-md border-gray-300 shadow-sm focus:border-accent focus:ring-accent sm:text-sm" placeholder="you@example.com">
      </div>
    </div>
    ```

### Tables

*   **Data Display:**
    ```html
    <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
      <table class="min-w-full divide-y divide-gray-300">
        <thead class="bg-gray-50">
          <tr>
            <th scope="col" class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-primary sm:pl-6">Title</th>
            <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-primary">Status</th>
            <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-6"></th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200 bg-white">
          <!-- Rows go here -->
        </tbody>
      </table>
    </div>
    ```

### Badges (Tags)

*   **Status Indicators:**
    ```html
    <!-- Completed -->
    <span class="inline-flex items-center rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-success">Completed</span>

    <!-- Processing -->
    <span class="inline-flex items-center rounded-full bg-yellow-100 px-2.5 py-0.5 text-xs font-medium text-yellow-800">Processing</span>
    ```

## 6. Iconography

*   **Library:** [Heroicons](https://heroicons.com/)
*   **Style:** `outline` 스타일을 기본으로 사용하여 깔끔하고 전문적인 느낌을 유지합니다.
*   **Usage:** 아이콘은 텍스트를 보조하는 역할로만 제한적으로 사용합니다. 장식적인 용도로 남용하지 않습니다.
