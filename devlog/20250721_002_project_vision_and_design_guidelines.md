# Echoes of Korea: Project Vision & Design Guidelines (Ruby on Rails)

## Project Vision: Voices Across Time and Borders

"Echoes of Korea"는 단순한 구술사 아카이브를 넘어, 시간과 국경을 초월하여 한국인의 목소리를 담아내는 살아있는 플랫폼입니다. 일제강점기와 한국전쟁을 겪은 세대의 개인적 경험부터, 전 세계에 흩어진 한인 디아스포라의 삶의 이야기와 노래까지, 이 플랫폼은 잊혀질 수 있는 소중한 기억과 감정을 기록하고 보존하며 공유하는 디지털 유산의 장이 될 것입니다. 우리는 기술을 통해 과거와 현재, 그리고 미래 세대를 연결하고, 다양한 삶의 궤적 속에서 피어난 한국인의 정체성과 문화를 조명하고자 합니다.

## What We Are Trying to Achieve

우리의 목표는 누구나 자신의 이야기를 구술하고, 노래를 남기며, 삶의 흔적을 기록할 수 있는 접근성 높은 온라인 시스템을 구축하는 것입니다. 이는 단순히 데이터를 수집하는 것을 넘어, 각 개인의 목소리가 지닌 고유한 가치를 인정하고, 이를 통해 집단적 기억을 형성하며, 궁극적으로는 인류의 문화적 다양성에 기여하는 것을 지향합니다. 우리는 사용자가 쉽고 안전하게 자신의 이야기를 공유할 수 있도록 지원하며, 기록된 모든 콘텐츠가 미래 연구와 교육을 위한 귀중한 자원이 되도록 할 것입니다.

## First Page Concept & Design Guidelines

첫 페이지는 방문자에게 프로젝트의 깊은 의미와 비전을 전달하고, 참여를 독려하는 감성적이고 신뢰감 있는 경험을 제공해야 합니다.

*   **Emotional Resonance:** 방문자의 마음을 움직이는 스토리텔링에 집중합니다. 과거의 사진, 상징적인 이미지, 또는 짧지만 강렬한 구술사의 인용구를 활용하여 감성적인 연결을 유도합니다.
*   **Sense of Connection:** 전 세계에 흩어진 한인들의 연결고리를 시각적으로 표현합니다. 지도를 활용하거나, 다양한 배경의 인물 이미지를 배치하여 디아스포라의 폭넓은 스펙트럼을 보여줄 수 있습니다.
*   **Trustworthiness & Authority:** 학술적 프로젝트로서의 신뢰성과 권위를 유지합니다. 깔끔하고 정돈된 레이아웃, 전문적인 타이포그래피, 그리고 차분한 색상 팔레트를 사용하여 진정성 있는 분위기를 조성합니다.
*   **Call to Action:** 명확하고 간결한 참여 유도 문구(예: "당신의 이야기를 남겨주세요", "기억을 공유하세요")를 배치하여 사용자가 다음 단계로 나아갈 수 있도록 안내합니다.
*   **Visual Simplicity:** 복잡함을 피하고, 핵심 메시지에 집중할 수 있도록 시각적 요소를 최소화합니다. 여백을 충분히 활용하여 콘텐츠가 숨 쉴 공간을 제공합니다.
*   **Audio/Visual Hint:** 오디오 녹음 및 구술사 프로젝트임을 암시하는 시각적 요소(예: 마이크 아이콘, 음파 이미지)를 은은하게 배치하여 프로젝트의 성격을 직관적으로 전달합니다.

---

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
